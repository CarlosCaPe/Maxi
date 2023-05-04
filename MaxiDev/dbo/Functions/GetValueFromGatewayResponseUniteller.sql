create function [dbo].[GetValueFromGatewayResponseUniteller]
(
    @XmlResponse xml,
    @Name nvarchar(max)
)
returns nvarchar(max)
Begin
declare @value nvarchar(max)

if (@Name='PAYMENTLOCALTIME')
begin
    select  @value=
        col.value('.', 'nvarchar(max)')
    from @XmlResponse.nodes('/UFSNotificationItem/PAYMENTLOCALTIME') as T(col)
end

if (@Name='PAYINGAGENTBRANCHCODE')
begin
    select  @value=
        col.value('.', 'nvarchar(max)')
    from @XmlResponse.nodes('/UFSNotificationItem/PAYINGAGENTBRANCHCODE') as T(col)
end

if (@Name='BENEIDENTIFICATIONTYPE')
begin
    select  @value=
        col.value('.', 'nvarchar(max)')
    from @XmlResponse.nodes('/UFSNotificationItem/BENEIDENTIFICATIONTYPE') as T(col)
end

if (@Name='BENEIDENTIFICATIONNUMBER')
begin
    select  @value=
        col.value('.', 'nvarchar(max)')
    from @XmlResponse.nodes('/UFSNotificationItem/BENEIDENTIFICATIONNUMBER') as T(col)
end

set @value =ISNULL(@value,'')	
return @value

End