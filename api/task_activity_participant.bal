public isolated service class TaskActivityParticipantData {

    private TaskActivityParticipant task_activity_participant;

    isolated function init(int? id = 0,TaskActivityParticipant? taskActivityParticipant = null) returns error? {

        if (taskActivityParticipant != null) {
            self.task_activity_participant = taskActivityParticipant.cloneReadOnly();
            return;
        }

        lock {
            TaskActivityParticipant task_activity_participant_raw;

            if (id > 0) {

                task_activity_participant_raw = check db_client->queryRow(
                `SELECT *
                FROM task_activity_participant
                WHERE id = ${id};`);

            }else {
                return error("Invalid request :id must be greater than 0");
            }

            self.task_activity_participant = task_activity_participant_raw.cloneReadOnly();

        }
    }

    isolated resource function get id() returns int?|error {
        lock {
            return self.task_activity_participant.id;
        }
    }

    isolated resource function get task_activity_instance_id() returns int?|error {
        lock {
            return self.task_activity_participant.task_activity_instance_id;
        }
    }

    isolated resource function get person_id() returns int?|error {
        lock {
            return self.task_activity_participant.person_id;
        }
    }

    isolated resource function get start_date() returns string?|error {
        lock {
            return self.task_activity_participant.start_date;
        }
    }

    isolated resource function get end_date() returns string?|error {
        lock {
            return self.task_activity_participant.end_date;
        }
    }

    isolated resource function get task_status() returns string?|error {
        lock {
            return self.task_activity_participant.task_status;
        }
    }

    isolated resource function get created() returns string?|error {
        lock {
            return self.task_activity_participant.created;
        }
    }

    isolated resource function get updated() returns string?|error {
        lock {
            return self.task_activity_participant.updated;
        }
    }

}
