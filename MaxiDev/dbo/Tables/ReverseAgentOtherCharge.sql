CREATE TABLE [dbo].[ReverseAgentOtherCharge] (
    [IdReverseAgentOtherCharge] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgentOtherCharge]        INT      NOT NULL,
    [DateOfLastChange]          DATETIME NOT NULL,
    [EnterByIdUser]             INT      NOT NULL,
    CONSTRAINT [PK_ReverseAgentOtherCharge] PRIMARY KEY CLUSTERED ([IdReverseAgentOtherCharge] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ReverseAgentOtherCharge_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

