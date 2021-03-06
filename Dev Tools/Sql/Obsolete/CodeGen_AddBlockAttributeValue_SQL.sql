/* 
	Code Generate SQL Queries to insert attribute values for a block.
*/

DECLARE @BlockId INT = 198

DECLARE @queries TABLE (query nvarchar(max))

DECLARE @crlf VARCHAR(2) = CHAR(13) + CHAR(10)
INSERT INTO @queries
SELECT DISTINCT
	'DECLARE @B_'+REPLACE(b.[Name],' ', '')+'Id int = ( SELECT TOP 1 [Id] FROM [Block] WHERE [Guid] = ''' + CONVERT(nvarchar(50), b.Guid) + ''' )'
	+ @crlf + @crlf
FROM [AttributeValue] [v]
JOIN [Attribute] [a] ON [a].[Id] = [v].[AttributeId]
LEFT JOIN [EntityType] [e] ON [e].[Id] = [a].[EntityTypeId]
JOIN [FieldType] [ft] ON [ft].[Id] = [a].[FieldTypeId]
LEFT JOIN [Block] [b] ON b.Id = [v].[EntityId]
WHERE [b].Id = @BlockId

INSERT INTO @queries
SELECT 
	'DECLARE @'+a.[Key]+'Id int = ( SELECT TOP 1 [Id] FROM [Attribute] WHERE [Guid] = ''' + CONVERT(nvarchar(50), a.Guid) + ''' )'
	+ @crlf
	+ 'INSERT INTO [AttributeValue] ([IsSystem], [AttributeId], [EntityId], [Value], [Guid])'
	+ @crlf
	+ 'VALUES('
	+ CONVERT(NVARCHAR(MAX), [v].[IsSystem]) + ', @'
	+ CONVERT(NVARCHAR(MAX), [a].[Key]) + 'Id, @B_'
	+ CONVERT(NVARCHAR(MAX), REPLACE([b].[Name],' ', '')) + 'Id, ''' 
	+ CONVERT(NVARCHAR(MAX), REPLACE([v].[Value],'''','''''')) + ''', '''
	+ CONVERT(NVARCHAR(50), [v].[Guid]) + ''')' 
	+ @crlf + @crlf AS [CodeGen BlockAttributeValues]
FROM [AttributeValue] [v]
JOIN [Attribute] [a] ON [a].[Id] = [v].[AttributeId]
LEFT JOIN [EntityType] [e] ON [e].[Id] = [a].[EntityTypeId]
JOIN [FieldType] [ft] ON [ft].[Id] = [a].[FieldTypeId]
LEFT JOIN [Block] [b] ON b.Id = [v].[EntityId]
WHERE [b].Id = @BlockId

SELECT * from @queries


