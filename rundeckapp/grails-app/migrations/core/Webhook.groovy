databaseChangeLog = {
    changeSet(author: "rundeckuser (generated)", id: "3.4.0-25") {
        createTable(tableName: "webhook") {
            column(autoIncrement: "true", name: "id", type: '${number.type}') {
                constraints(nullable: "false", primaryKey: "true", primaryKeyName: "webhookPK")
            }

            column(name: "version", type: '${number.type}') {
                constraints(nullable: "false")
            }

            column(name: "event_plugin", type: '${varchar255.type}') {
                constraints(nullable: "false")
            }

            column(name: "plugin_configuration_json", type: '${text.type}') {
                constraints(nullable: "false")
            }

            column(name: "uuid", type: '${varchar255.type}')

            column(name: "name", type: '${varchar255.type}') {
                constraints(nullable: "false")
            }

            column(name: "enabled", type: '${boolean.type}') {
                constraints(nullable: "false")
            }

            column(name: "project", type: '${varchar255.type}') {
                constraints(nullable: "false")
            }

            column(name: "auth_token", type: '${varchar255.type}') {
                constraints(nullable: "false")
            }
        }
    }
}