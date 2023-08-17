public isolated service class DutyParticipantData{

   private DutyParticipant duty_participant;

   isolated function init(int? id = 0,int? activity_id=0,int? person_id = 0,DutyParticipant? duty_participant=null) returns error?{
        
        if(duty_participant !=null){
          self.duty_participant = duty_participant.cloneReadOnly();
          return;
        }

        lock{
            DutyParticipant duty_participant_raw;

            if(id > 0 ) {

               duty_participant_raw = check db_client->queryRow(
                `SELECT *
                FROM duty_participant
                WHERE id = ${id};`);
           
            }else if (activity_id > 0 ){

              duty_participant_raw = check db_client->queryRow(
                `SELECT *
                FROM duty_participant
                WHERE activity_id = ${activity_id};`);

            }else{

               duty_participant_raw = check db_client->queryRow(
                `SELECT *
                FROM duty_participant
                WHERE person_id = ${person_id};`);
            }
            self.duty_participant = duty_participant_raw.cloneReadOnly();
        
         }
   }
    
   isolated resource function get id() returns int?|error {
        lock {
            return self.duty_participant.id;
        }
   }

   isolated resource function get person_id() returns int? {
        lock {
                return self.duty_participant.person_id;
        }
    }
    

   isolated resource function get person() returns PersonData|error? {
       int id =0;
       lock{
         id = self.duty_participant.person_id ?: 0;
         if(id == 0){
            return null;
         }

       }

      return new PersonData((),id);
   }



   isolated resource function get activity() returns ActivityData|error? {
     int activity_id = 0;
     lock{
        activity_id = self.duty_participant.activity_id ?:0;
        if(activity_id == 0){
          return null;
        }
     }

     return new ActivityData((),activity_id);

   }

   isolated resource function get activity_id() returns int? {
        lock {
                return self.duty_participant.activity_id;
        }
   }


   isolated resource function get role() returns string? {
        lock {
                return self.duty_participant.role;
        }
   }

   isolated resource function get start_date() returns string? {
        lock {
                return self.duty_participant.start_date;
        }
    }

   isolated resource function get end_date() returns string? {
        lock {
                return self.duty_participant.end_date;
        }
   }

   isolated resource function get created() returns string? {
        lock {
                return self.duty_participant.created;
        }
    }

   isolated resource function get updated() returns string? {
        lock {
                return self.duty_participant.updated;
        }
   }

}