﻿CREATE TABLE [dbo].[UsersTemp] (
    [IdUser]                    INT            IDENTITY (1, 1) NOT NULL,
    [UserName]                  NVARCHAR (MAX) NOT NULL,
    [UserLogin]                 NVARCHAR (MAX) NOT NULL,
    [UserPassword]              NVARCHAR (MAX) NOT NULL,
    [DateOfCreation]            DATETIME       NOT NULL,
    [CreatedByIdUser]           INT            NOT NULL,
    [IdUserType]                INT            NOT NULL,
    [ChangePasswordAtNextLogin] BIT            DEFAULT ((1)) NOT NULL,
    [AllowToRegisterPc]         BIT            DEFAULT ((0)) NOT NULL,
    [IdGenericStatus]           INT            NOT NULL,
    [salt]                      NVARCHAR (50)  NOT NULL,
    [DateOfLastChange]          DATETIME       NULL,
    [EnterByIdUser]             INT            NOT NULL,
    [FirstName]                 NVARCHAR (100) NULL,
    [LastName]                  NVARCHAR (50)  NULL,
    [SecondLastName]            NVARCHAR (50)  NULL,
    CONSTRAINT [PK_UsersTemp] PRIMARY KEY CLUSTERED ([IdUser] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_UsersTemp_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_UsersTemp_UsersType] FOREIGN KEY ([IdUserType]) REFERENCES [dbo].[UsersType] ([IdUserType])
);

