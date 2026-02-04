# Erlang-chat-app

Simple chat application with a JSP front end and an Erlang backend.

## Overview

**Distribuirani chat sistem** sa arhitekturom klijent-server koji omogućava višekorisničku komunikaciju u realnom vremenu preko web interfejsa.

### Ključne karakteristike:
- ✅ **Real-time komunikacija** između korisnika
- ✅ **Distribuirana arhitektura** - frontend i backend na odvojenim serverima
- ✅ **Višekorisnički sistem** - više korisnika istovremeno
- ✅ **Perzistencija sesije** preko `sessionStorage`
- ✅ **REST API** komunikacija
- ✅ **Actor Model** pattern za konkurentnost

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