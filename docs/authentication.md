# Authentication architecture

AuthShield implements a Session authentication Standard Flow.
In this aprouch every time the user logs in we generate an session and returns it on a cookie.

## Session Authentication Flow

In this flow AuthShield will check if the user is active and has an active / valid session.

![Session Authentication Flow](https://raw.githubusercontent.com/lcpojr/auth_shield/master/docs/images/session-authentication-flow.png);
