defmodule AuthShield.ResourcesTest do
  use AuthShield.DataCase, async: true

  alias AuthShield.{DelegatorMock, Resources}
  alias AuthShield.Resources.Schemas.{Application, Permission, Role, Scope, User}

  describe "AuthShield.Resources" do
    # USERS RESOURCES

    test "delegates from create_user/1 to user #{inspect(Users)}.insert/1" do
      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :create_user}, {Resources.Users, :insert}, [params] ->
          {:ok, insert(:user, params)}
        end
      )

      assert Resources.create_user(params_for(:user))
    end

    test "delegates from create_user!/1 to user #{inspect(Users)}.insert!/1" do
      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :create_user!}, {Resources.Users, :insert!}, [params] ->
          insert(:user, params)
        end
      )

      assert Resources.create_user!(params_for(:user))
    end

    test "delegates from update_user/2 to user #{inspect(Users)}.update/2" do
      user = insert(:user)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :update_user}, {Resources.Users, :update}, [%User{} = user, _params] ->
          {:ok, user}
        end
      )

      assert Resources.update_user(user, params_for(:user))
    end

    test "delegates from update_user!/2 to user #{inspect(Users)}.update!/2" do
      user = insert(:user)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :update_user!}, {Resources.Users, :update!}, [%User{} = user, _params] ->
          user
        end
      )

      assert Resources.update_user!(user, params_for(:user))
    end

    test "delegates from list_users/1 to user #{inspect(Users)}.list/1" do
      user = insert(:user)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :list_users}, {Resources.Users, :list}, [filters] ->
          assert user.id == filters[:user_id]
          [user]
        end
      )

      assert Resources.list_users(user_id: user.id)
    end

    test "delegates from get_user_by/1 to user #{inspect(Users)}.get_by/1" do
      user = insert(:user)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :get_user_by}, {Resources.Users, :get_by}, [filters] ->
          assert user.id == filters[:user_id]
          user
        end
      )

      assert Resources.get_user_by(user_id: user.id)
    end

    test "delegates from get_user_by!/1 to user #{inspect(Users)}.get_by!/1" do
      user = insert(:user)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :get_user_by!}, {Resources.Users, :get_by!}, [filters] ->
          assert user.id == filters[:user_id]
          user
        end
      )

      assert Resources.get_user_by!(user_id: user.id)
    end

    test "delegates from delete_user/1 to user #{inspect(Users)}.delete/1" do
      user = insert(:user)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :delete_user}, {Resources.Users, :delete}, [%User{} = user] ->
          {:ok, user}
        end
      )

      assert Resources.delete_user(user)
    end

    test "delegates from delete_user!/1 to user #{inspect(Users)}.delete!/1" do
      user = insert(:user)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :delete_user!}, {Resources.Users, :delete!}, [%User{} = user] ->
          user
        end
      )

      assert Resources.delete_user!(user)
    end

    test "delegates from change_status_user/2 to user #{inspect(Users)}.change_status/2" do
      user = insert(:user)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :change_status_user},
           {Resources.Users, :change_status},
           [%User{} = user, _status] ->
          {:ok, user}
        end
      )

      assert Resources.change_status_user(user, true)
    end

    test "delegates from change_status_user!/2 to user #{inspect(Users)}.change_status!/2" do
      user = insert(:user)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :change_status_user!},
           {Resources.Users, :change_status!},
           [%User{} = user, _status] ->
          user
        end
      )

      assert Resources.change_status_user!(user, true)
    end

    test "delegates from change_locked_user/2 to user #{inspect(Users)}.change_locked/2" do
      user = insert(:user)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :change_locked_user},
           {Resources.Users, :change_locked},
           [%User{} = user, _status] ->
          {:ok, user}
        end
      )

      assert Resources.change_locked_user(user, true)
    end

    test "delegates from change_locked_user!/2 to user #{inspect(Users)}.change_locked!/2" do
      user = insert(:user)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :change_locked_user!},
           {Resources.Users, :change_locked!},
           [%User{} = user, _status] ->
          user
        end
      )

      assert Resources.change_locked_user!(user, true)
    end

    test "delegates from change_roles_user/2 to user #{inspect(Users)}.change_roles/2" do
      user = insert(:user)
      role = insert(:role)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :change_roles_user},
           {Resources.Users, :change_roles},
           [%User{} = user, [%Role{}]] ->
          {:ok, user}
        end
      )

      assert Resources.change_roles_user(user, [role])
    end

    test "delegates from change_roles_user!/2 to user #{inspect(Users)}.change_roles!/2" do
      user = insert(:user)
      role = insert(:role)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :change_roles_user!},
           {Resources.Users, :change_roles!},
           [%User{} = user, [%Role{}]] ->
          user
        end
      )

      assert Resources.change_roles_user!(user, [role])
    end

    test "delegates from preload_user/2 to user #{inspect(Users)}.preload/2" do
      user = insert(:user)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :preload_user}, {Resources.Users, :preload}, [%User{} = user, [:roles]] ->
          user
        end
      )

      assert Resources.preload_user(user, [:roles])
    end

    # PERMISSIONS RESOURCES

    test "delegates from create_permission/1 to permission #{inspect(Permissions)}.insert/1" do
      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :create_permission}, {Resources.Permissions, :insert}, [params] ->
          {:ok, insert(:permission, params)}
        end
      )

      assert Resources.create_permission(params_for(:permission))
    end

    test "delegates from create_permission!/1 to permission #{inspect(Permissions)}.insert!/1" do
      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :create_permission!}, {Resources.Permissions, :insert!}, [params] ->
          insert(:permission, params)
        end
      )

      assert Resources.create_permission!(params_for(:permission))
    end

    test "delegates from update_permission/2 to permission #{inspect(Permissions)}.update/2" do
      permission = insert(:permission)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :update_permission},
           {Resources.Permissions, :update},
           [%Permission{} = permission, _params] ->
          {:ok, permission}
        end
      )

      assert Resources.update_permission(permission, params_for(:permission))
    end

    test "delegates from update_permission!/2 to permission #{inspect(Permissions)}.update!/2" do
      permission = insert(:permission)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :update_permission!},
           {Resources.Permissions, :update!},
           [%Permission{} = permission, _params] ->
          permission
        end
      )

      assert Resources.update_permission!(permission, params_for(:permission))
    end

    test "delegates from list_permissions/1 to permission #{inspect(Permissions)}.list/1" do
      permission = insert(:permission)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :list_permissions}, {Resources.Permissions, :list}, [filters] ->
          assert permission.id == filters[:permission_id]
          [permission]
        end
      )

      assert Resources.list_permissions(permission_id: permission.id)
    end

    test "delegates from get_permission_by/1 to permission #{inspect(Permissions)}.get_by/1" do
      permission = insert(:permission)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :get_permission_by}, {Resources.Permissions, :get_by}, [filters] ->
          assert permission.id == filters[:permission_id]
          permission
        end
      )

      assert Resources.get_permission_by(permission_id: permission.id)
    end

    test "delegates from get_permission_by!/1 to permission #{inspect(Permissions)}.get_by!/1" do
      permission = insert(:permission)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :get_permission_by!}, {Resources.Permissions, :get_by!}, [filters] ->
          assert permission.id == filters[:permission_id]
          permission
        end
      )

      assert Resources.get_permission_by!(permission_id: permission.id)
    end

    test "delegates from delete_permission/1 to permission #{inspect(Permissions)}.delete/1" do
      permission = insert(:permission)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :delete_permission},
           {Resources.Permissions, :delete},
           [%Permission{} = permission] ->
          {:ok, permission}
        end
      )

      assert Resources.delete_permission(permission)
    end

    test "delegates from delete_permission!/1 to permission #{inspect(Permissions)}.delete!/1" do
      permission = insert(:permission)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :delete_permission!},
           {Resources.Permissions, :delete!},
           [%Permission{} = permission] ->
          permission
        end
      )

      assert Resources.delete_permission!(permission)
    end

    # ROLES RESOURCES

    test "delegates from create_role/1 to role #{inspect(Roles)}.insert/1" do
      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :create_role}, {Resources.Roles, :insert}, [params] ->
          {:ok, insert(:role, params)}
        end
      )

      assert Resources.create_role(params_for(:role))
    end

    test "delegates from create_role!/1 to role #{inspect(Roles)}.insert!/1" do
      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :create_role!}, {Resources.Roles, :insert!}, [params] ->
          insert(:role, params)
        end
      )

      assert Resources.create_role!(params_for(:role))
    end

    test "delegates from update_role/2 to role #{inspect(Roles)}.update/2" do
      role = insert(:role)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :update_role}, {Resources.Roles, :update}, [%Role{} = role, _params] ->
          {:ok, role}
        end
      )

      assert Resources.update_role(role, params_for(:role))
    end

    test "delegates from update_role!/2 to role #{inspect(Roles)}.update!/2" do
      role = insert(:role)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :update_role!}, {Resources.Roles, :update!}, [%Role{} = role, _params] ->
          role
        end
      )

      assert Resources.update_role!(role, params_for(:role))
    end

    test "delegates from list_roles/1 to role #{inspect(Roles)}.list/1" do
      role = insert(:role)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :list_roles}, {Resources.Roles, :list}, [filters] ->
          assert role.id == filters[:role_id]
          [role]
        end
      )

      assert Resources.list_roles(role_id: role.id)
    end

    test "delegates from get_role_by/1 to role #{inspect(Roles)}.get_by/1" do
      role = insert(:role)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :get_role_by}, {Resources.Roles, :get_by}, [filters] ->
          assert role.id == filters[:role_id]
          role
        end
      )

      assert Resources.get_role_by(role_id: role.id)
    end

    test "delegates from get_role_by!/1 to role #{inspect(Roles)}.get_by!/1" do
      role = insert(:role)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :get_role_by!}, {Resources.Roles, :get_by!}, [filters] ->
          assert role.id == filters[:role_id]
          role
        end
      )

      assert Resources.get_role_by!(role_id: role.id)
    end

    test "delegates from delete_role/1 to role #{inspect(Roles)}.delete/1" do
      role = insert(:role)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :delete_role}, {Resources.Roles, :delete}, [%Role{} = role] ->
          {:ok, role}
        end
      )

      assert Resources.delete_role(role)
    end

    test "delegates from delete_role!/1 to role #{inspect(Roles)}.delete!/1" do
      role = insert(:role)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :delete_role!}, {Resources.Roles, :delete!}, [%Role{} = role] ->
          role
        end
      )

      assert Resources.delete_role!(role)
    end

    test "delegates from change_permissions_role/2 to role #{inspect(Roles)}.change_permissions/2" do
      role = insert(:role)
      permission = insert(:permission)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :change_permissions_role},
           {Resources.Roles, :change_permissions},
           [%Role{} = role, [%Permission{}]] ->
          role
        end
      )

      assert Resources.change_permissions_role(role, [permission])
    end

    test "delegates from change_permissions_role!/2 to role #{inspect(Roles)}.change_permissions!/2" do
      role = insert(:role)
      permission = insert(:permission)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :change_permissions_role!},
           {Resources.Roles, :change_permissions!},
           [%Role{} = role, [%Permission{}]] ->
          role
        end
      )

      assert Resources.change_permissions_role!(role, [permission])
    end

    # APPLICATIONS RESOURCES

    test "delegates from create_application/1 to application #{inspect(Applications)}.insert/1" do
      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :create_application}, {Resources.Applications, :insert}, [params] ->
          {:ok, insert(:application, params)}
        end
      )

      assert Resources.create_application(params_for(:application))
    end

    test "delegates from create_application!/1 to application #{inspect(Applications)}.insert!/1" do
      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :create_application!}, {Resources.Applications, :insert!}, [params] ->
          insert(:application, params)
        end
      )

      assert Resources.create_application!(params_for(:application))
    end

    test "delegates from update_application/2 to application #{inspect(Applications)}.update/2" do
      application = insert(:application)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :update_application},
           {Resources.Applications, :update},
           [%Application{} = application, _params] ->
          {:ok, application}
        end
      )

      assert Resources.update_application(application, params_for(:application))
    end

    test "delegates from update_application!/2 to application #{inspect(Applications)}.update!/2" do
      application = insert(:application)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :update_application!},
           {Resources.Applications, :update!},
           [%Application{} = application, _params] ->
          application
        end
      )

      assert Resources.update_application!(application, params_for(:application))
    end

    test "delegates from list_applications/1 to application #{inspect(Applications)}.list/1" do
      application = insert(:application)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :list_applications}, {Resources.Applications, :list}, [filters] ->
          assert application.id == filters[:application_id]
          [application]
        end
      )

      assert Resources.list_applications(application_id: application.id)
    end

    test "delegates from get_application_by/1 to application #{inspect(Applications)}.get_by/1" do
      application = insert(:application)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :get_application_by}, {Resources.Applications, :get_by}, [filters] ->
          assert application.id == filters[:application_id]
          application
        end
      )

      assert Resources.get_application_by(application_id: application.id)
    end

    test "delegates from get_application_by!/1 to application #{inspect(Applications)}.get_by!/1" do
      application = insert(:application)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :get_application_by!}, {Resources.Applications, :get_by!}, [filters] ->
          assert application.id == filters[:application_id]
          application
        end
      )

      assert Resources.get_application_by!(application_id: application.id)
    end

    test "delegates from delete_application/1 to application #{inspect(Applications)}.delete/1" do
      application = insert(:application)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :delete_application},
           {Resources.Applications, :delete},
           [%Application{} = application] ->
          {:ok, application}
        end
      )

      assert Resources.delete_application(application)
    end

    test "delegates from delete_application!/1 to application #{inspect(Applications)}.delete!/1" do
      application = insert(:application)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :delete_application!},
           {Resources.Applications, :delete!},
           [%Application{} = application] ->
          application
        end
      )

      assert Resources.delete_application!(application)
    end

    test "delegates from change_status_application/2 to application #{inspect(Applications)}.change_status/2" do
      application = insert(:application)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :change_status_application},
           {Resources.Applications, :change_status},
           [%Application{} = application, _status] ->
          {:ok, application}
        end
      )

      assert Resources.change_status_application(application, true)
    end

    test "delegates from change_status_application!/2 to application #{inspect(Applications)}.change_status!/2" do
      application = insert(:application)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :change_status_application!},
           {Resources.Applications, :change_status!},
           [%Application{} = application, _status] ->
          application
        end
      )

      assert Resources.change_status_application!(application, true)
    end

    test "delegates from change_scopes_application/2 to application #{inspect(Applications)}.change_scopes/2" do
      application = insert(:application)
      scope = insert(:scope)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :change_scopes_application},
           {Resources.Applications, :change_scopes},
           [%Application{} = application, [%Scope{}]] ->
          {:ok, application}
        end
      )

      assert Resources.change_scopes_application(application, [scope])
    end

    test "delegates from change_scopes_application!/2 to application #{inspect(Applications)}.change_scopes!/2" do
      application = insert(:application)
      scope = insert(:scope)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :change_scopes_application!},
           {Resources.Applications, :change_scopes!},
           [%Application{} = application, [%Scope{}]] ->
          application
        end
      )

      assert Resources.change_scopes_application!(application, [scope])
    end

    test "delegates from preload_application/2 to application #{inspect(Applications)}.preload/2" do
      application = insert(:application)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :preload_application},
           {Resources.Applications, :preload},
           [%Application{} = application, [:scopes]] ->
          application
        end
      )

      assert Resources.preload_application(application, [:scopes])
    end

    # SCOPES RESOURCES

    test "delegates from create_scope/1 to scope #{inspect(Scopes)}.insert/1" do
      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :create_scope}, {Resources.Scopes, :insert}, [params] ->
          {:ok, insert(:scope, params)}
        end
      )

      assert Resources.create_scope(params_for(:scope))
    end

    test "delegates from create_scope!/1 to scope #{inspect(Scopes)}.insert!/1" do
      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :create_scope!}, {Resources.Scopes, :insert!}, [params] ->
          insert(:scope, params)
        end
      )

      assert Resources.create_scope!(params_for(:scope))
    end

    test "delegates from update_scope/2 to scope #{inspect(Scopes)}.update/2" do
      scope = insert(:scope)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :update_scope}, {Resources.Scopes, :update}, [%Scope{} = scope, _params] ->
          {:ok, scope}
        end
      )

      assert Resources.update_scope(scope, params_for(:scope))
    end

    test "delegates from update_scope!/2 to scope #{inspect(Scopes)}.update!/2" do
      scope = insert(:scope)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :update_scope!},
           {Resources.Scopes, :update!},
           [%Scope{} = scope, _params] ->
          scope
        end
      )

      assert Resources.update_scope!(scope, params_for(:scope))
    end

    test "delegates from list_scopes/1 to scope #{inspect(Scopes)}.list/1" do
      scope = insert(:scope)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :list_scopes}, {Resources.Scopes, :list}, [filters] ->
          assert scope.id == filters[:scope_id]
          [scope]
        end
      )

      assert Resources.list_scopes(scope_id: scope.id)
    end

    test "delegates from get_scope_by/1 to scope #{inspect(Scopes)}.get_by/1" do
      scope = insert(:scope)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :get_scope_by}, {Resources.Scopes, :get_by}, [filters] ->
          assert scope.id == filters[:scope_id]
          scope
        end
      )

      assert Resources.get_scope_by(scope_id: scope.id)
    end

    test "delegates from get_scope_by!/1 to scope #{inspect(Scopes)}.get_by!/1" do
      scope = insert(:scope)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :get_scope_by!}, {Resources.Scopes, :get_by!}, [filters] ->
          assert scope.id == filters[:scope_id]
          scope
        end
      )

      assert Resources.get_scope_by!(scope_id: scope.id)
    end

    test "delegates from delete_scope/1 to scope #{inspect(Scopes)}.delete/1" do
      scope = insert(:scope)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :delete_scope}, {Resources.Scopes, :delete}, [%Scope{} = scope] ->
          {:ok, scope}
        end
      )

      assert Resources.delete_scope(scope)
    end

    test "delegates from delete_scope!/1 to scope #{inspect(Scopes)}.delete!/1" do
      scope = insert(:scope)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :delete_scope!}, {Resources.Scopes, :delete!}, [%Scope{} = scope] ->
          scope
        end
      )

      assert Resources.delete_scope!(scope)
    end

    test "delegates from change_applications_scope/2 to scope #{inspect(Scopes)}.change_applications/2" do
      scope = insert(:scope)
      application = insert(:application)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :change_applications_scope},
           {Resources.Scopes, :change_applications},
           [%Scope{} = scope, [%Application{}]] ->
          scope
        end
      )

      assert Resources.change_applications_scope(scope, [application])
    end

    test "delegates from change_applications_scope/2 to scope #{inspect(Scopes)}.change_applications!/2" do
      scope = insert(:scope)
      application = insert(:application)

      expect(
        DelegatorMock,
        :apply,
        fn {Resources, :change_applications_scope!},
           {Resources.Scopes, :change_applications!},
           [%Scope{} = scope, [%Application{}]] ->
          scope
        end
      )

      assert Resources.change_applications_scope!(scope, [application])
    end
  end
end
