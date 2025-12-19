public isolated service class MaintenanceTaskData {

    private MaintenanceTask maintenance_task;

    isolated function init(int? id = 0,MaintenanceTask? maintenanceTask = null) returns error? {

        if (maintenanceTask != null) {
            self.maintenance_task = maintenanceTask.cloneReadOnly();
            return;
        }

        lock {
            MaintenanceTask maintenance_task_raw;

            if (id > 0) {

                maintenance_task_raw = check db_client->queryRow(
                `SELECT *
                FROM maintenance_task
                WHERE id = ${id};`);

            } else{
               return error("Invalid request : id  must be greater than 0");
            }

            self.maintenance_task = maintenance_task_raw.cloneReadOnly();

        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.maintenance_task.id;
        }
    }

    isolated resource function get title() returns string?|error {
        lock {
            return self.maintenance_task.title;
        }
    }

    isolated resource function get description() returns string?|error {
        lock {
            return self.maintenance_task.description;
        }
    }

    isolated resource function get task_type() returns string?|error {
        lock {
            return self.maintenance_task.task_type;
        }
    }

    isolated resource function get frequency() returns string?|error {
        lock {
            return self.maintenance_task.frequency;
        }
    }

    isolated resource function get location_id() returns int?|error {
        lock {
            return self.maintenance_task.location_id;
        }
    }

    isolated resource function get start_date() returns string?|error {
        lock {
            return self.maintenance_task.start_date;
        }
    }

    isolated resource function get exception_deadline() returns int?|error {
        lock {
            return self.maintenance_task.exception_deadline;
        }
    }

    isolated resource function get has_financial_info() returns int?|error {
        lock {
            return self.maintenance_task.has_financial_info;
        }
    }

    isolated resource function get modified_by() returns string?|error {
        lock {
            return self.maintenance_task.modified_by;
        }
    }

    isolated resource function get is_active() returns boolean?|error {
        lock {
            return self.maintenance_task.is_active;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.maintenance_task.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.maintenance_task.updated;
        }
    }

}
