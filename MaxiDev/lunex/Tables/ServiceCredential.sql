CREATE TABLE [lunex].[ServiceCredential] (
    [IdServiceCredential] INT            IDENTITY (1, 1) NOT NULL,
    [AuthKey]             NVARCHAR (MAX) NOT NULL,
    [Host]                NVARCHAR (MAX) NOT NULL,
    [IpAddress]           NVARCHAR (20)  NOT NULL,
    [Realm]               NVARCHAR (500) NOT NULL,
    [URL]                 NVARCHAR (MAX) NOT NULL,
    [HostUser]            NVARCHAR (MAX) NOT NULL
);

