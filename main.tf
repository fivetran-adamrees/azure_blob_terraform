provider "fivetran" {
  api_key    = var.fivetran_api_key
  api_secret = var.fivetran_api_secret
}

resource "fivetran_connection_v2" "azure_blob" {
  service                  = "azure_blob_storage"
  group_id                 = var.group_id
  destination_schema_names = "FIVETRAN_NAMING"
  run_setup_tests          = true

  config = {
    schema               = "azure_blob_test"
    container_name       = "ts-adls-blob-demo"
    storage_account_name = var.azure_storage_account_name
    auth_method          = "CONNECTION_STRING"
    connection_string    = var.azure_connection_string
    connection_method    = "DIRECT"
    prefix               = "data/"
    file_type            = "csv"
    on_error             = "fail"

    file_mapping_method  = "DEFINE_PER_TABLE"
    files = [
      {
        file_pattern = "orders/.*\\.csv"
        table_name   = "orders"
      },
      {
        file_pattern = "customers/.*\\.csv"
        table_name   = "customers"
      }
    ]
  }
}

resource "fivetran_connector_schedule" "azure_blob" {
  connector_id    = fivetran_connection_v2.azure_blob.id
  schedule_type   = "auto"
  sync_frequency  = "1440"
  daily_sync_time = "00:00"
  paused          = false
}