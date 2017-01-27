/**
* Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
* www.ortussolutions.com
* ---
* Simple utility for extracting SQL from native Criteria Query objects
*/
component accessors="true"{

    /**
    * The log array
    */
    property name="log" type="array";

    /**
    * Format the SQL or not.
    */
    property name="formatSql" type="boolean"  default="false";

    /**
    * Bit to return the executable SQL or not
    */
    property name="returnExecutableSql" type="boolean"  default="false";

    /**
    * Constructor
    * @criteriaBuilder The builder this helper is linked to
    * @returnExecutableSql To return the executable SQL or not
    * @formatSQL Pretty format the SQL or not
    */
    SQLHelper function init( 
        required any criteriaBuilder,
        boolean returnExecutableSql = false, 
        boolean formatSql = false  
    ){

        // Setup properties
        variables.cb            = arguments.criteriaBuilder;
        variables.entityName    = variables.cb.getEntityName();
        variables.criteriaImpl  = variables.cb.getNativeCriteria();
        variables.ormSession    = variables.criteriaImpl.getSession();
        variables.factory       = ormSession.getFactory();
        
        // get formatter for sql string beautification
        if( findNoCase( "coldfusion", server.coldfusion.productName ) AND 
            listFirst( server.coldfusion.productVersion ) gte 11
        ){
            variables.formatter  = createObject( "java", "org.hibernate.engine.jdbc.internal.BasicFormatterImpl" );
        } else {
            variables.formatter  = createObject( "java", "org.hibernate.jdbc.util.BasicFormatterImpl" );
        }
        
        // set properties
        variables.log                   = [];
        variables.formatSQL             = arguments.formatSQL;
        variables.returnExecutableSql   = arguments.returnExecutableSql;

        return this;
    }

    /**
     * Logs current state of criteria to internal tracking log
     * @label The label for the log record
     */
    SQLHelper function log( required string label="Criteria" ) {
        var logentry = {
            "type" = arguments.label,
            "sql"  = getSQL( argumentCollection=arguments )
        };
        arrayAppend( variables.log, logentry );

        return this;
    }

    /**
     * Returns the SQL string that will be prepared for the criteria object at the time of request
     * @returnExecutableSql Whether or not to do query param replacements on returned SQL string
     * @formatSql Whether to format the sql
     */
    string function getSQL( 
        required boolean returnExecutableSql=getReturnExecutableSql(), 
        required boolean formatSql=getFormatSql() 
    ){

        var sql             = getCriteriaJoinWalker().getSQLstring();
        var selection       = getQueryParameters().getRowSelection();
        var useLimit        = useLimit( selection );
        var hasFirstRow     = getFirstRow( selection ) > 0;
        var useOffset       = hasFirstRow && useLimit && getDialect().supportsLimitOffset();
       
        // try to add limit/offset in
        if( useLimit ) {
            sql = getDialect().getLimitstring( 
                sql, 
                useOffset ? getFirstRow(selection) : 0,
                getMaxOrLimit( selection )
            );
        }

        // if we want executable sql string...
        if( arguments.returnExecutableSql ) {
            sql = replaceQueryParameters( sql, arguments.formatSql );
        }
        
        // if we want to beautify the sql string
        if( arguments.formatSql ) {
            sql = applyFormatting( sql );
        }
        
        return sql;
    }

    /**
     * Applies pretty formatting to a sql string
     * @sql The SQL string to format
     */
    string function applyFormatting( required string sql ) {
        return "<pre>" & variables.formatter.format( arguments.sql ) & "</pre>";
    }

    /** 
     * Gets the positional SQL parameter values from the criteria query
     * return array
     */
    array function getPositionalSQLParameterValues() {
        return getCriteriaQueryTranslator().getQueryParameters().getPositionalParameterValues();
    }

    /**
     * Gets positional SQL parameter types from the criteria query
     * @simple Whether to return a simply array or full objects
     */
    any function getPositionalSQLParameterTypes( required Boolean simple=true ) {
        var types = getCriteriaQueryTranslator().getQueryParameters().getPositionalParameterTypes();
        if( !arguments.simple ) {
            return types;
        }
        var simplifiedTypes = [];
        for( var x=1; x <= arrayLen( types ); x++ ) {
            arrayAppend( simplifiedTypes, types[ x ].getName() );
        }
        return simplifiedTypes;
    }

    /**
     * Returns a formatted array of parameter value and types
     */
    array function getPositionalSQLParameters() {
        var params = [];
        var values = getPositionalSQLParameterValues();
        var types  = getPositionalSQLParameterTypes( true );
        // loop over them
        for( var x=1; x <= arrayLen( types ); x++ ) {
            arrayAppend( params, {
                "type" = types [ x ],
                "value" = values[ x ]
            });
        }
        return params;
    }

    /**
     * Generates a unique SQL Alias within the criteria query
     */
    string function generateSQLAlias() {
        return getCriteriaQueryTranslator().generateSQLAlias();
    }

    /**
     * Retrieves the "rooted" SQL alias for the criteria query
     */
    string function getRootSQLAlias() {
        return getCriteriaQueryTranslator().getRootSQLAlias();
    }

    /**
     * Retrieves the projected types of the criteria query
     */
    any function getProjectedTypes() {
        return getCriteriaQueryTranslator().getProjectedTypes();
    }

    /**
     * Get the alias of the current projection
     */
    string function getProjectionAlias() {
        return getCriteriaQueryTranslator().getProjectedAliases()[ 1 ];
    }

    /**
     * Retrieves the correct dialect of the database engine
     */
    any function getDialect() {
        return variables.factory.getDialect();
    }

    /**
    * Is there a limit in the logging offset
    */
    Boolean function canLogLimitOffset() {
        var dialect = getDialect();
        var max     = !isNull( variables.criteriaImpl.getMaxResults() ) ? variables.criteriaImpl.getMaxResults() : 0;
        return dialect.supportsLimitOffset() && max > 0;
    }

    /********************************* PRIVATE *********************************/

    /**
     * Small utility method to convert weird arrays from Java methods into something CF understands
     * @array {Array} The array to convert
     * return Array
     */
    private array function convertToCFArray( required any array ) {
        var newArray = [];
        newArray.addAll( createObject( "java", "java.util.Arrays" ).asList( arguments.array ) );
        return newArray;
    }

    /**
     * Gets currently applied query parameters for the query object
     * return org.hibernate.engine.QueryParameters
     */
    private any function getQueryParameters() {
        var translator = getCriteriaQueryTranslator();
        return translator.getQueryParameters();
    }

    /**
     * replace query parameter placeholders with their actual values (for detachedSQLProjection)
     * @sql The sql string to massage
     */
    private string function replaceQueryParameters( required string sql ) {
        var dialect = getDialect();
        var parameters = getQueryParameters();
        // get parameter values and types
        var values = parameters.getPositionalParameterValues();
        var types  = parameters.getPositionalParameterTypes();
        // get query so we can see full number of ordinal parameters
        var query = ormsession.createSQLQuery( arguments.sql );
        var meta = query.getParameterMetaData();
        var positionalParameterCount = meta.getOrdinalParameterCount();
        // get row selection
        var selection = parameters.getRowSelection();
        // prepare some meta about the limit info...need to handle this separately
        var useLimit = useLimit( selection );
        var firstRow = dialect.convertToFirstRowValue( getFirstRow( selection ) );
        var hasFirstRow = dialect.supportsLimitOffset() && ( firstRow > 0 || dialect.forceLimitUsage() );
        var useOffset = hasFirstRow && useLimit && dialect.supportsLimitOffset();
        var reverse = dialect.bindLimitParametersInReverseOrder();
        /** 
            APPROACH: 
            Unfortunately, there does not seem to be any really good way to retrieve the SQL that will be executed,
            since it isn't actually sent to the db engine as executable SQL
            So, we have to rely upon the QueryTranslator to provide us details about positional paramters that are going to be sent
            However, the "limit/offset" data isn't handled by the Translator, so we also need to spin up a regular SQL Query to determine
            how many total ordinal parameters are getting sent with the query string. 

            This, combined with info that Hibernate knows about each db dialect, we can smartly fill in the gaps for the "limit/offset"
            information, as well as fill in the ordinal parameters values and return a SQL string that is as close to the actual string 
            that will be executed on the db as possible.

            So the actual idea is to take the ordinal parameter values and types which QueryTranslator knows about, and intelligently add to 
            those lists based on the dialect of the database engine.
         */
        // if we have positional parameters
        if( positionalParameterCount ) {
            var positionalValues = convertToCFArray( values );
            var positionalTypes = convertToCFArray( types );
            // if our query at this point in time is using "limit/offset"
            if( useLimit ) {
                // we'll reuse this
                var integerType = createObject( "java", "org.hibernate.type.IntegerType" );
                // Ex: Engines like SQL Server put limits first
                if( dialect.bindLimitParametersFirst() ) {
                    positionalValues = bindLimitParameters( positionalValues, false, selection );
                    // add for max/limit
                    arrayInsertAt( positionalTypes, 1, integerType );
                    if( hasFirstRow ) {
                        arrayInsertAt( positionalTypes, 1, integerType );
                    }
                }
                // Ex: Engines like MySQL put limits last
                else {
                    positionalValues = bindLimitParameters( positionalValues, true, selection );
                    // append for max/limit
                    arrayAppend( positionalTypes, integerType );
                    if( hasFirstRow ) {
                        arrayAppend( positionalTypes, integerType );
                    }
                }
            }
            // loop over parameters; need to replace those pesky "?" with the real values
            for( var x=1; x<=arrayLen( positionalTypes ); x++ ) {
                var type = positionalTypes[ x ];
                var value = positionalValues[ x ];
                // cast values to appropriate SQL type
                if( !type.isAssociationType() && type.getName() != "text" ) {
                    var pvTyped = type.objectToSQLstring( value, getDialect() );
                    // remove parameter placeholders
                    arguments.sql = reReplaceNoCase( arguments.sql, "\?", pvTyped, "one" );
                }
                else if( type.getName() == "text" ) {
                    // remove parameter placeholders
                    arguments.sql = reReplaceNoCase( arguments.sql, "\?", "'#value#'", "one" );
                }
                // association values can't be cast to SQL string by normal convention; just do a simple replace
                else {
                    arguments.sql = reReplaceNoCase( arguments.sql, "\?", value, "one" );
                }
            }
            // for some reason, JoinWalker doesn't sync up root paramters with the generated alias...so fix those
            arguments.sql = reReplaceNoCase( arguments.sql, "this\.", "this_.", "all" );
        }
        return arguments.sql;
    }

    /**
     * Inserts parameter values into the running list based on the dialect of the database engine
     * @positionalValues The positional values for this query
     * @append Whether values are appended or prepended to the array
     * @selection The current row selection
     */
    private Array function bindLimitParameters( 
        required Array positionalValues, 
        required Boolean append, 
        required any selection 
    ){
        var dialect = getDialect();
        // trackers
        var newPositionalValues = [];
        var finalArray          = [];
        // prepare some meta about the limit info
        var firstRow    = dialect.convertToFirstRowValue( getFirstRow( arguments.selection ) );
        var lastRow     = getMaxOrLimit( arguments.selection );
        var hasFirstRow = dialect.supportsLimitOffset() && ( firstRow > 0 || dialect.forceLimitUsage() );
        var reverse     = dialect.bindLimitParametersInReverseOrder();
        // has offset...need to add both limit and offset
        if ( hasFirstRow ) {
            // if offset/limit are reversed
            // EX: Other engines "reverse" this and use: LIMIT {limit}, {offset}
            if( reverse ) {
                arrayAppend( newPositionalValues, arguments.selection.getMaxRows() );
                arrayAppend( newPositionalValues, firstRow );
            }
            // EX: In MySQL, offset limit are: LIMIT {offset}, {limit}
            else {
                arrayAppend( newPositionalValues, firstRow );
                arrayAppend( newPositionalValues, arguments.selection.getMaxRows() );
            }
        }
        // no start row...just add regular limit
        else {
            arrayAppend( newPositionalValues, arguments.selection.getMaxRows() );
        }
        // APPEND: Engines like MySQL, etc. put limit/offset at the end of the statement
        if( arguments.append ) {
            arguments.positionalValues.addAll( newPositionalValues );
            return arguments.positionalValues;
        }
        // PREPEND:Engines like SQL Server, etc. use top/row numbering
        else {
            newPositionalValues.addAll( arguments.positionalValues );
            return newPositionalValues;
        }
    }

    /**
     * Determines whether the database engine allows for the use of "limit/offset" syntax
     * @selection The current row selection
     */
    private Boolean function useLimit( required any selection ) {
        return getDialect().supportsLimit() && hasMaxRows( argumentCollection=arguments );
    }

    /**
     * Determines whether the current row selection has a limit already applied
     * @selection The current row selection
     */
    private Boolean function hasMaxRows( required any selection ) {
        return !isNull( arguments.selection.getMaxRows() );
    }

    /**
     * Gets the first row (or 0) for the current row selection
     * @selection The current row selection
     */
    private Numeric function getFirstRow( required any selection ) {
        return isNull( arguments.selection.getFirstRow() ) ? 0 : arguments.selection.getFirstRow().intValue();
    }

    /**
     * Gets correct "limit" value for the current row selection
     * @selection The current row selection
     */
    private Numeric function getMaxOrLimit( required any selection ) {
        var dialect     = getDialect();
        var firstRow    = dialect.convertToFirstRowValue( getFirstRow( arguments.selection ) );
        var lastRow     = arguments.selection.getMaxRows().intValue();
        return dialect.useMaxForLimit() ? lastRow + firstRow : lastRow;
    }

    /** 
     * gets an instance of CriteriaJoinWalker, which can allow for translating criteria query into a sql string
     * @return org.hibernate.loader.criteria.CriteriaJoinWalker
     */
    private any function getCriteriaJoinWalker() {
        // not nearly as cool as the walking dead kind, but is still handy for turning a criteria into a sql string ;)
        return createObject( "java", "org.hibernate.loader.criteria.CriteriaJoinWalker" ).init(
            variables.factory.getEntityPersister( variables.entityName ), // persister (loadable)
            getCriteriaQueryTranslator(), // translator 
            variables.factory, // factory
            variables.criteriaImpl, // criteria
            variables.entityName, // rootEntityName
            variables.ormSession.getLoadQueryInfluencers() // loadQueryInfluencers
        );
    }

    /** 
     * gets an instance of CriteriaQueryTranslator, which can prepares criteria query for conversion to SQL
     * @return org.hibernate.loader.criteria.CriteriaQueryTranslator
     */
    private any function getCriteriaQueryTranslator() {
        // create new criteria query translator; we'll use this to build up the query string
        return createObject( "java", "org.hibernate.loader.criteria.CriteriaQueryTranslator" ).init(
            variables.factory, // factory
            variables.criteriaImpl, // criteria
            variables.entityName,  // rootEntityName
            variables.criteriaImpl.getAlias() // rootSQLAlias
        );  
    } 
}