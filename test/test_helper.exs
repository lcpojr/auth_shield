# Exchmachina for tests
{:ok, _} = Application.ensure_all_started(:ex_machina)

Mox.defmock(AuthShield.DelegatorMock, for: Delx.Delegator)

ExUnit.start()
