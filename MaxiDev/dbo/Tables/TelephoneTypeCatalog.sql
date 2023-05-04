CREATE TABLE [dbo].[TelephoneTypeCatalog] (
    [IdTelephoneType]  INT          NOT NULL,
    [TelephoneType]    VARCHAR (20) NOT NULL,
    [DateOfLastChange] DATETIME     NOT NULL,
    [EnterByIdUser]    VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_IdTelephoneType] PRIMARY KEY CLUSTERED ([IdTelephoneType] ASC)
);

