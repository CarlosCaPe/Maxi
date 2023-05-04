CREATE TABLE [dbo].[CheckDetails] (
    [IdCheckDetail]  INT           IDENTITY (1, 1) NOT NULL,
    [IdCheck]        INT           NOT NULL,
    [IdStatus]       INT           NOT NULL,
    [DateOfMovement] DATETIME      NOT NULL,
    [Note]           VARCHAR (MAX) NULL,
    [EnterByIdUser]  INT           NULL,
    CONSTRAINT [PK_ChecksDetails] PRIMARY KEY CLUSTERED ([IdCheckDetail] ASC),
    CONSTRAINT [FK_ChecksDetails_Cheks] FOREIGN KEY ([IdCheck]) REFERENCES [dbo].[Checks] ([IdCheck])
);


GO
CREATE NONCLUSTERED INDEX [CheckDetailsIncludeIdCheckDetailIdStatusDateOfMovementEnterByIdUser]
    ON [dbo].[CheckDetails]([IdCheck] ASC)
    INCLUDE([IdCheckDetail], [IdStatus], [DateOfMovement], [EnterByIdUser], [Note]);

