# Supavisor pooler configuration
# This Elixir script configures the connection pooler

# Configure the pooler for the default tenant
Supavisor.Tenants.create_tenant(%{
  id: System.get_env("POOLER_TENANT_ID", "default"),
  db_host: System.get_env("POSTGRES_HOST", "db"),
  db_port: String.to_integer(System.get_env("POSTGRES_PORT", "5432")),
  db_database: System.get_env("POSTGRES_DB", "postgres"),
  default_pool_size: String.to_integer(System.get_env("POOLER_DEFAULT_POOL_SIZE", "20")),
  max_client_conn: String.to_integer(System.get_env("POOLER_MAX_CLIENT_CONN", "100"))
})
