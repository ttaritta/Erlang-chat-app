# Erlang-chat-app

Simple chat application with a JSP front end and an Erlang backend.

## Structure
- my_jsp_app/ — JSP pages and web.xml
- proba/ — Erlang application (rebar3)

## Important note
The JSP app and the Erlang backend are separate components and must be started independently.

## Run instructions

### Erlang backend (rebar3)
1. Install Erlang/OTP and rebar3.
2. Open a terminal in the [proba](proba) folder.
3. Run:
	- `rebar3 shell`

### JSP app
1. Deploy the [my_jsp_app](my_jsp_app) folder to a Java web container (e.g., Tomcat).
2. Ensure the container uses a compatible Java version.
3. Start the server and open the login page.

## Notes
- Front end pages: login.jsp, chat.jsp, users.jsp
- Erlang sources in proba/src