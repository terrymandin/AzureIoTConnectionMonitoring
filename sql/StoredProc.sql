-- drop procedure UpdateConnectionStatus;

/*
exec UpdateConnectionStatus '124', 'myHub', '04-may-2022', 'Connected', 'Sequence001'

select * from tblConnectionStatus where deviceId = 'SampleDevice' order by statusTimeStamp desc;
select * from tblConnectionHistory where deviceId = 'SampleDevice' order by statusTimeStamp desc;

delete from tblConnectionStatus;
delete from tblConnectionHistory;


*/

create PROCEDURE UpdateConnectionStatus
    @deviceId nvarchar(256),
    @iothub nvarchar(256),
    @statusTimeStamp DATETIME,
    @status nvarchar(256),
    @sequenceNumber nvarchar(256)
AS
    DECLARE @count bigint;
    declare @statusId bigint;

    select @count = count(*)
    from tblConnectionStatus
    where deviceId = @deviceId
    and iothub = @iotHub;

    if (@count = 0)
    begin
        insert into tblConnectionStatus
        (
            deviceId,
            iotHub,
            statusTimeStamp,
            status,
            sequenceNumber
        )
        VALUES
        (
            @deviceId,
            @iothub,
            @statusTimeStamp,
            @status,
            @sequenceNumber
        )

        select @statusId = id 
        from tblConnectionStatus
        where deviceId = @deviceId
        and iotHub = @iotHub;
    end
    else 
    begin
        select @statusId = id 
        from tblConnectionStatus
        where deviceId = @deviceId
        and iotHub = @iotHub;
        
        update tblConnectionStatus
        set deviceId = @deviceId,
            iotHub = @iotHub,
            statusTimeStamp = @statusTimeStamp,
            status = @status,
            sequenceNumber = @sequenceNumber
        where id = @statusId;
    end

    insert into tblConnectionHistory
    (
        statusId,
        deviceId,
        iotHub,
        statusTimeStamp,
        status,
        sequenceNumber
    )
    values
    (
        @statusId,
        @deviceId,
        @iothub,
        @statusTimeStamp,
        @status,
        @sequenceNumber
    )
GO
