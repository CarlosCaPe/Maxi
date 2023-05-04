CREATE TABLE [dbo].[State_BK191113] (
    [IdState]          INT            IDENTITY (1, 1) NOT NULL,
    [StateName]        NVARCHAR (MAX) NOT NULL,
    [IdCountry]        INT            NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    [StateCode]        VARCHAR (MAX)  NULL,
    [StateCodeBTS]     NVARCHAR (MAX) NULL,
    [StateCodeISO3166] NVARCHAR (6)   NULL,
    [SendLicense]      BIT            NULL
);

