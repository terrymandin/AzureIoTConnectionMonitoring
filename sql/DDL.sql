select * from sysobjects where xtype = 'U'

drop table tblConnectionStatus;

create table tblConnectionStatus
(
    id bigint IDENTITY not null,
    deviceId nvarchar(256) not null,
    iotHub nvarchar(256) not null,
    statusTimeStamp DATETIME not null,
    status nvarchar(256) not null,
    sequenceNumber nvarchar(256) not null
);

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
    'device123',
    'myHub',
    GETDATE(),
    'Connected',
    'q31231223423423342'
)

delete from tblConnectionStatus;

select * from tblConnectionStatus;

drop table tblConnectionHistory;

create table tblConnectionHistory
(
    id bigint IDENTITY not null,
    statusId bigint not null,
    deviceId nvarchar(256) not null,
    iotHub nvarchar(256) not null,
    statusTimeStamp DATETIME not null,
    status nvarchar(256) not null,
    sequenceNumber nvarchar(256) not null
);