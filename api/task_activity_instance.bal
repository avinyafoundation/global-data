public isolated service class TaskActivityInstanceData {

    private TaskActivityInstance task_activity_instance;

    isolated function init(int? id = 0, TaskActivityInstance? taskActivityInstance = null) returns error? {

        if (taskActivityInstance != null) {
            self.task_activity_instance = taskActivityInstance.cloneReadOnly();
            return;
        }

        lock {
            TaskActivityInstance task_activity_instance_raw;

            if (id > 0) {

                task_activity_instance_raw = check db_client->queryRow(
                `SELECT *
                FROM task_activity_instance
                WHERE id = ${id};`);

            }else {
                return error("Invalid request : id must be greater than 0");
            }

            self.task_activity_instance = task_activity_instance_raw.cloneReadOnly();

        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.task_activity_instance.id;
        }
    }

    isolated resource function get activity_id() returns int?|error {
        lock {
            return self.task_activity_instance.activity_id;
        }
    }

    isolated resource function get task_id() returns int?|error {
        lock {
            return self.task_activity_instance.task_id;
        }
    }

    isolated resource function get start_date() returns string?|error {
        lock {
            return self.task_activity_instance.start_date;
        }
    }

    isolated resource function get end_date() returns string?|error {
        lock {
            return self.task_activity_instance.end_date;
        }
    }

    isolated resource function get task_status() returns string?|error {
        lock {
            return self.task_activity_instance.task_status;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.task_activity_instance.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.task_activity_instance.updated;
        }
    }

}
