CREATE TABLE [dbo].[ZipCode] (
    [ZipCode]          INT           NOT NULL,
    [StateCode]        VARCHAR (10)  NOT NULL,
    [StateName]        VARCHAR (200) NOT NULL,
    [CityName]         VARCHAR (200) NOT NULL,
    [IdCounty]         INT           NULL,
    [IdGenericStatus]  INT           DEFAULT ((1)) NOT NULL,
    [EnterByIdUser]    INT           NULL,
    [DateOfLastChange] DATETIME      NULL,
    CONSTRAINT [PK_Zipcode] PRIMARY KEY CLUSTERED ([ZipCode] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_zipcode_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_zipcode_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

