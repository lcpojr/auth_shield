# Authorization architecture

AuthShield implements a [Role Bases Access controll](https://en.m.wikipedia.org/wiki/Role-based_access_control). That means that every user should have at least one role to use the authorization flow.

This aproach simplify the authorization management by grouping the permissions in set of roles that can be used in order to authorize or unauthorized an request. Because of that permissions are not directly related to users, but to the roles.

Roles and permissions can be easily created and related to the users (or each other in case of permissions).

## Role authorization flow

In this flow AuthShield will check if the user has **ONE** or **ALL** the required roles to perform the action.

[Role authorization Flow]();

## Permition authorization Flow

In this flow AuthShield will check if **ONE** or **ALL** the roles has a required permition to perform the action.

[Permission authorization Flow]();
