CREATE TABLE [dbo].[CallStatus] (
    [IdCallStatus]     INT            IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (50)  NOT NULL,
    [Description]      NVARCHAR (100) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    [VisibleToUser]    BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CallStatus] PRIMARY KEY CLUSTERED ([IdCallStatus] ASC) WITH (FILLFACTOR = 90)
);

