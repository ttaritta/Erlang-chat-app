# Erlang-chat-app

Simple chat application with a JSP front end and an Erlang backend.

## Overview

**Distributed chat system** with a client-server architecture that enables multi-user, real-time communication through a web interface.

### Key features:
- ✅ **Real-time communication** between users
- ✅ **Distributed architecture** - frontend and backend on separate servers
- ✅ **Multi-user system** - multiple users at the same time
- ✅ **Session persistence** via `sessionStorage`
- ✅ **REST API** communication
- ✅ **Actor Model** pattern for concurrency

---

## Architecture (high level)

Browser → JSP app (Tomcat) → HTTP REST → Erlang backend (Cowboy)

- The JSP app renders pages and makes HTTP requests to the backend.
- The Erlang backend keeps chat state and serves REST endpoints.
- The two components run independently and communicate over HTTP.

## Technologies

### Frontend
- JSP (JavaServer Pages)
- JavaScript (Fetch API, DOM updates)
- Apache Tomcat (servlet container)

### Backend
- Erlang/OTP
- Cowboy HTTP server
- Rebar3 (build tool)

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
4. The backend listens on port 8082 by default.

### JSP app
1. Deploy the [my_jsp_app](my_jsp_app) folder to a Java web container (e.g., Tomcat).
2. Ensure the container uses a compatible Java version.
3. Start the server and open the login page.

## Notes
- Front end pages: login.jsp, chat.jsp, users.jsp
- Erlang sources in proba/src