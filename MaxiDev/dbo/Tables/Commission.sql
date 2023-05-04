CREATE TABLE [dbo].[Commission] (
    [IdCommission]     INT            IDENTITY (1, 1) NOT NULL,
    [CommissionName]   NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    CONSTRAINT [PK_Commission] PRIMARY KEY CLUSTERED ([IdCommission] ASC) WITH (FILLFACTOR = 90)
);

