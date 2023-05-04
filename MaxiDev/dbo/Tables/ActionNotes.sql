CREATE TABLE [dbo].[ActionNotes] (
    [IdNote]            INT            IDENTITY (1, 1) NOT NULL,
    [Note]              NVARCHAR (MAX) NOT NULL,
    [Type]              INT            NOT NULL,
    [Action]            INT            NOT NULL,
    [IsEnabled]         BIT            NOT NULL,
    [BankReason]        VARCHAR (MAX)  NULL,
    [ReturnedReason_ID] INT            NULL,
    CONSTRAINT [PK_ActionNotes] PRIMARY KEY CLUSTERED ([IdNote] ASC)
);

