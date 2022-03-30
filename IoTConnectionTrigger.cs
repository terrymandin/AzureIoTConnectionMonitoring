// Default URL for triggering event grid function in the local environment.
// http://localhost:7071/runtime/webhooks/EventGrid?functionName={functionname}
using System;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Azure.EventGrid.Models;
using Microsoft.Azure.WebJobs.Extensions.EventGrid;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace IOTConnectionMonitoring
{
    public static class IoTConnectionTrigger
    {
        static SqlConnection sqlConnection = null;

        [FunctionName("IoTConnectionTrigger")]
        public static void Run([EventGridTrigger]JObject eventGridEvent, ILogger log)
        {
            log.LogInformation(eventGridEvent.ToString(Formatting.Indented));

            try
            {
                // dotnet add package System.Data.SqlClient --version 4.8.3
                if (sqlConnection == null)
                {
                    var sqlConnectionString = Environment.GetEnvironmentVariable("sqldb_connection");
                    sqlConnection = new SqlConnection(sqlConnectionString);
                    log.LogInformation("Opening the connection");
                    sqlConnection.Open();
                }   

                using (SqlCommand cmd = new SqlCommand()) 
                {
                    Int32 rowsAffected;

                    cmd.CommandText = "UpdateConnectionStatus";
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Connection = sqlConnection;

                    log.LogInformation("Creating Parameters");
                    cmd.Parameters.Add(new SqlParameter("@deviceId", eventGridEvent.SelectToken("data.deviceId").ToString()));
                    cmd.Parameters.Add(new SqlParameter("@iothub", eventGridEvent.SelectToken("data.hubName").ToString()));
                    cmd.Parameters.Add(new SqlParameter("@statusTimeStamp", eventGridEvent.SelectToken("eventTime").ToString()));
                    cmd.Parameters.Add(new SqlParameter("@status", eventGridEvent.SelectToken("eventType").ToString().Replace("Microsoft.Devices.","")));
                    cmd.Parameters.Add(new SqlParameter("@sequenceNumber", eventGridEvent.SelectToken("data.deviceConnectionStateEventInfo.sequenceNumber").ToString()));

                    log.LogInformation("Executing stored procedure");
                    rowsAffected = cmd.ExecuteNonQuery();

                }
            } catch (Exception ex)
            {
                log.LogInformation("Error: " + ex.Message);
                log.LogInformation("Stack trace: " + ex.StackTrace);
            }
        }
    }
}
