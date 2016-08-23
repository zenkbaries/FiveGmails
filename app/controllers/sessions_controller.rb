# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  layout false

  def new
  end

  def create
    @auth = request.env['omniauth.auth']
    # need this token to work with google services
    @access_token = @auth["credentials"]["token"]
    @refresh_token = @auth["credentials"]["refresh_token"]
    @expires_at = @auth["credentials"]["expires_at"]

    # Save credentials in DB, session or yaml file - in my case i am saving
    # in auth table, it may be comfortable to save all omniauth tokens
    # in one table if you use many providers like facebook, twitter...
    Token.create(:access_token => @access_token,
    :refresh_token => @refresh_token, :expires_at => @expires_at )

    #   access_token: @auth['token'],
    #   refresh_token: @auth['refresh_token'],
    #   expires_at: Time.at(@auth['expires_at']).to_datetime
    # )

    #What data comes back from OmniAuth?
    # @auth = request.env['omniauth.auth']
    #Use the token from the data to request a list of calendars
    # @token = @auth['credentials']['token']
    client = Google::APIClient.new
    calendar = Google::Apis::CalendarV3::CalendarService.new
    # client.authorization.access_token = @token
    calendar.authorization = credentials_for(Google::Apis::CalendarV3::AUTH_CALENDAR)
    calendar_id = 'primary'
    @result = calendar.list_events(
      calendar_id,
      max_results: 10,
      single_events: true,
      order_by: 'startTime',
      time_min: Time.now.iso8601
      )
    # service = client.discovered_api('calendar', 'v3')
    # @result = client.execute(
    #   :api_method => service.calendar_list.list,
    #   :parameters => {},
    #   :headers => {'Content-Type' => 'application/json'})
  end
end
