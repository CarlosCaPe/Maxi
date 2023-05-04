CREATE TABLE [dbo].[SpecialChangeStatusValidation] (
    [IdSpecialChangeStatusValidation] INT IDENTITY (1, 1) NOT NULL,
    [FromIdStatus]                    INT NULL,
    [ToIdStatus]                      INT NULL,
    [IdBalance]                       INT NULL
);

