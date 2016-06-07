ExUnit.start

Mix.Task.run "ecto.create", ~w(-r EdmBackend.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r EdmBackend.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(EdmBackend.Repo)

