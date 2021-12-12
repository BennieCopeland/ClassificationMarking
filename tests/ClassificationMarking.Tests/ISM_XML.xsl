<?xml version="1.0" encoding="UTF-8"?>
<!--UNCLASSIFIED--><xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:schold="http://www.ascc.net/xml/schematron"
                xmlns:iso="http://purl.oclc.org/dsdl/schematron"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:ism="urn:us:gov:ic:ism"
                xmlns:ntk="urn:us:gov:ic:ntk"
                xmlns:catt="urn:us:gov:ic:taxonomy:catt:tetragraph"
                xmlns:cve="urn:us:gov:ic:cve"
                xmlns:dvf="deprecated:value:function"
                xmlns:util="urn:us:gov:ic:ism:xsl:util"
                version="2.0"><!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->
<xsl:param name="archiveDirParameter"/>
   <xsl:param name="archiveNameParameter"/>
   <xsl:param name="fileNameParameter"/>
   <xsl:param name="fileDirParameter"/>
   <xsl:variable name="document-uri">
      <xsl:value-of select="document-uri(/)"/>
   </xsl:variable>

   <!--PHASES-->


<!--PROLOG-->
<xsl:output xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
               method="xml"
               omit-xml-declaration="no"
               standalone="yes"
               indent="yes"/>

   <!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->
<xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:contributesToRollup"
                 as="xs:boolean">
      <xsl:param name="context"/>
      <xsl:value-of select="not(string($context/@ism:excludeFromRollup) = string(true()))"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="dvf:deprecated"
                 as="xs:string*">
      <xsl:param name="attribute" as="xs:string"/>
      <xsl:param name="depTerms" as="element()*"/>
      <xsl:param name="curDate" as="xs:date?"/>
      <xsl:param name="isError" as="xs:boolean"/>
      
      <xsl:if test="count($curDate) = 1">
         <xsl:for-each select="$depTerms[cve:Value = tokenize($attribute, ' ')]">
            <xsl:if test="($isError and $curDate gt xs:date(@deprecated)) or (not($isError) and $curDate le xs:date(@deprecated))">
               <xsl:sequence select="concat('[', string(current()/cve:Value), '] has been deprecated and is not authorized for use after  ', current()/@deprecated)"/>
            </xsl:if>
         </xsl:for-each>
      </xsl:if>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:containsAnyTokenMatching"
                 as="xs:boolean">
      <xsl:param name="attribute"/>
      <xsl:param name="regexList" as="xs:string+"/>
      <xsl:value-of select="             some $attrToken in tokenize(normalize-space(string($attribute)), ' ')                satisfies (some $regex in $regexList                   satisfies matches($attrToken, $regex))"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:containsAnyOfTheTokens"
                 as="xs:boolean">
      <xsl:param name="attribute"/>
      <xsl:param name="tokenList" as="xs:string*"/>
      <xsl:value-of select="             some $attrToken in tokenize(normalize-space(string($attribute)), ' ')                satisfies $attrToken = $tokenList"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:containsOnlyTheTokens"
                 as="xs:boolean">
      <xsl:param name="attribute"/>
      <xsl:param name="tokenList" as="xs:string*"/>
      <xsl:value-of select="             every $attrToken in tokenize(normalize-space(string($attribute)), ' ')                satisfies $attrToken = $tokenList"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:existInTokenSet"
                 as="xs:boolean">
      <xsl:param name="stringTokenValue"/>
      <xsl:param name="tokenList" as="xs:string*"/>
      <xsl:value-of select="tokenize($stringTokenValue, ' ') = $tokenList"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:getStringFromSequenceWithOnlyRegexValues"
                 as="xs:string">
      <xsl:param name="attrValues"/>
      <xsl:param name="regex"/>
      <xsl:variable name="StringWithOnlyRegexValues">
         <xsl:for-each select="$attrValues">
            
            <xsl:if test="matches(current(), $regex)">
               <xsl:value-of select="current()"/>
            </xsl:if>
            <xsl:value-of select="' '"/>
         </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="normalize-space(string($StringWithOnlyRegexValues))"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:getStringFromSequenceWithoutRegexValues"
                 as="xs:string">
      <xsl:param name="attrValues"/>
      <xsl:param name="regex"/>
      <xsl:variable name="StringWithoutRegexValues">
         <xsl:for-each select="$attrValues">
            
            <xsl:if test="not(matches(current(), $regex))">
               <xsl:value-of select="current()"/>
            </xsl:if>
            <xsl:value-of select="' '"/>
         </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="normalize-space(string($StringWithoutRegexValues))"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:getStringFromSequence"
                 as="xs:string">
      <xsl:param name="attrValues"/>
      <xsl:variable name="StringValues">
         <xsl:for-each select="$attrValues">
            <xsl:value-of select="current()"/>
            <xsl:value-of select="' '"/>
         </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="normalize-space(string($StringValues))"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:nonalphabeticValues"
                 as="xs:string">
      <xsl:param name="attrValues"/>
      <xsl:variable name="badValues">
         <xsl:for-each select="$attrValues">
            
            <xsl:if test="not(index-of($attrValues, current())[last()] = count($attrValues))">
               
               <xsl:if test="compare(current(), $attrValues[index-of($attrValues, current()) + 1]) = 1">
                  <xsl:value-of select="$attrValues[index-of($attrValues, current()) + 1]"/>
               </xsl:if>
               <xsl:value-of select="' '"/>
            </xsl:if>
         </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="normalize-space(string($badValues))"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:relativeOrderBetweenACCMAndNonACCMWhenExcludeFromRollup"
                 as="xs:string">
      <xsl:param name="attrValues" as="xs:string*"/>

      <xsl:variable name="badValues">
         <xsl:for-each select="$attrValues">
            
            <xsl:if test="not(index-of($attrValues, current())[last()] = count($attrValues))">
               
               <xsl:if test="not(matches(current(), $ACCMRegex)) and matches($attrValues[index-of($attrValues, current()) + 1], $ACCMRegex) and not(util:existInTokenSet(current(), $nonACCMLeftSetTok))">
                  <xsl:value-of select="current()"/>
               </xsl:if>
               
               <xsl:if test="matches(current(), $ACCMRegex) and not(matches($attrValues[index-of($attrValues, current()) + 1], $ACCMRegex)) and not(util:existInTokenSet($attrValues[index-of($attrValues, current()) + 1], $nonACCMRightSetTok))">
                  <xsl:value-of select="$attrValues[index-of($attrValues, current()) + 1]"/>
               </xsl:if>
               <xsl:value-of select="' '"/>
            </xsl:if>
         </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="normalize-space(string($badValues))"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:unorderedValues"
                 as="xs:string">
      <xsl:param name="attrValues" as="xs:string*"/>
      <xsl:param name="tokenList" as="xs:string*"/>

      <xsl:variable name="badValues">
         <xsl:for-each select="$attrValues">
            
            <xsl:if test="not(index-of($attrValues, current())[last()] = count($attrValues))">

               
               <xsl:variable name="indexOfValue"
                             select="util:getIndexFromListMatch(current(), $tokenList)"/>
               <xsl:variable name="indexOfNextValue"
                             select="util:getIndexFromListMatch($attrValues[index-of($attrValues, current()) + 1], $tokenList)"/>


               <xsl:choose>
                  <xsl:when test="$indexOfValue = $indexOfNextValue">
                     
                     
                     <xsl:if test="compare(current(), $attrValues[index-of($attrValues, current()) + 1]) = 1">
                        <xsl:value-of select="$attrValues[index-of($attrValues, current()) + 1]"/>
                     </xsl:if>
                  </xsl:when>
                  <xsl:when test="$indexOfValue &gt; $indexOfNextValue">
                     
                     <xsl:value-of select="$attrValues[index-of($attrValues, current()) + 1]"/>
                  </xsl:when>
               </xsl:choose>
               <xsl:value-of select="' '"/>
            </xsl:if>
         </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="normalize-space(string($badValues))"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:unsortedValues"
                 as="xs:string">
      <xsl:param name="attribute"/>
      <xsl:param name="tokenList" as="xs:string*"/>
      <xsl:variable name="attrValues"
                    select="tokenize(normalize-space(string($attribute)), ' ')"/>

      <xsl:variable name="badValues">
         <xsl:for-each select="$attrValues">
            
            <xsl:if test="not(index-of($attrValues, current())[last()] = count($attrValues))">

               
               <xsl:variable name="indexOfValue"
                             select="util:getIndexFromListMatch(current(), $tokenList)"/>
               <xsl:variable name="indexOfNextValue"
                             select="util:getIndexFromListMatch($attrValues[index-of($attrValues, current()) + 1], $tokenList)"/>


               <xsl:choose>
                  <xsl:when test="$indexOfValue = $indexOfNextValue">
                     
                     
                     <xsl:if test="compare(current(), $attrValues[index-of($attrValues, current()) + 1]) = 1">
                        <xsl:value-of select="$attrValues[index-of($attrValues, current()) + 1]"/>
                     </xsl:if>
                  </xsl:when>
                  <xsl:when test="$indexOfValue &gt; $indexOfNextValue">
                     
                     <xsl:value-of select="$attrValues[index-of($attrValues, current()) + 1]"/>
                  </xsl:when>
               </xsl:choose>
               <xsl:value-of select="' '"/>
            </xsl:if>
         </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="normalize-space(string($badValues))"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:getIndexFromListMatch"
                 as="xs:integer">
      <xsl:param name="value" as="xs:string"/>
      <xsl:param name="list" as="xs:string*"/>

      <xsl:variable name="index">
         <xsl:for-each select="$list">
            <xsl:if test="matches($value, concat('^', current(), '$'))">
               <xsl:value-of select="index-of($list, current())[1]"/>
            </xsl:if>
         </xsl:for-each>
      </xsl:variable>

      <xsl:choose>
         <xsl:when test="$index = ''">
            <xsl:value-of select="-1"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="number($index[1])"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:meetsType"
                 as="xs:boolean">
      <xsl:param name="value"/>
      <xsl:param name="typePattern" as="xs:string"/>
      <xsl:value-of select="matches(normalize-space(string($value)), concat('^(', $typePattern, ')$'))"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:getCountriesForTetra"
                 as="xs:string*">
      <xsl:param name="tetra" as="xs:string"/>

      <xsl:sequence select="$decomposableTetraElems[catt:TetraToken/text() = $tetra]/catt:Membership/catt:Country/text()"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:padValue"
                 as="xs:string">
      <xsl:param name="value" as="xs:string?"/>

      <xsl:value-of select="concat(' ', normalize-space($value), ' ')"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:tokenize"
                 as="xs:string*">
      <xsl:param name="value" as="xs:string?"/>

      <xsl:sequence select="tokenize(normalize-space($value), ' ')"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:join"
                 as="xs:string">
      <xsl:param name="values" as="xs:string*"/>

      <xsl:sequence select="normalize-space(string-join($values, ' '))"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:sort"
                 as="xs:string*">
      <xsl:param name="values" as="xs:string*"/>

      <xsl:variable name="sortedValues">
         <xsl:for-each select="$values">
            <xsl:sort select="."/>
            <xsl:value-of select="util:padValue(.)"/>
         </xsl:for-each>
      </xsl:variable>

      <xsl:sequence select="util:tokenize($sortedValues)"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:countIn"
                 as="xs:double">
      <xsl:param name="value" as="xs:string"/>
      <xsl:param name="expandedRelToStrings" as="xs:string*"/>
      <xsl:param name="countryHash" as="item()*"/>

      <xsl:variable name="counts" as="xs:integer*">
         <xsl:for-each select="$expandedRelToStrings">
            <xsl:if test="util:containsAnyOfTheTokens(., $value)">
               
               <xsl:variable name="expandedPosition" select="position()"/>
               <xsl:sequence select="$countryHash[position() = $expandedPosition * 2]"/>
            </xsl:if>
         </xsl:for-each>
      </xsl:variable>

      <xsl:sequence select="sum($counts)"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:isSubsetOf"
                 as="xs:boolean">
      <xsl:param name="subset" as="xs:string*"/>
      <xsl:param name="superset" as="xs:string*"/>

      <xsl:sequence select="             (every $subsetToken in $subset                satisfies $subsetToken = $superset)"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:containsDecomposableTetra"
                 as="xs:boolean">
      <xsl:param name="relTo" as="xs:string?"/>

      <xsl:sequence select="normalize-space($relTo) and util:containsAnyOfTheTokens($relTo, $decomposableTetras)"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:expandAllTetras"
                 as="xs:string*">
      <xsl:param name="relToStrings" as="xs:string*"/>

      <xsl:variable name="allTokens" as="xs:string*">
         <xsl:for-each select="$relToStrings">
            <xsl:variable name="expandedCountryTokens" select="util:expandDecomposableTetras(.)"/>
            <xsl:value-of select="util:padValue(util:join($expandedCountryTokens))"/>
         </xsl:for-each>
      </xsl:variable>

      <xsl:sequence select="$allTokens"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:expandDecomposableTetras"
                 as="xs:string*">
      <xsl:param name="relTo" as="xs:string"/>

      <xsl:variable name="expandedTetras">
         <xsl:choose>
            <xsl:when test="util:containsDecomposableTetra($relTo)">
               <xsl:variable name="currTetra"
                             select="util:tokenize($relTo)[. = $decomposableTetras][1]"/>
               <xsl:variable name="currTetraCountries"
                             select="util:join(util:getCountriesForTetra($currTetra))"/>
               <xsl:variable name="expandCurrTetra"
                             select="replace(util:padValue($relTo), util:padValue($currTetra), util:padValue($currTetraCountries))"/>

               <xsl:value-of select="util:expandDecomposableTetras($expandCurrTetra)"/>
            </xsl:when>

            <xsl:otherwise>
               <xsl:value-of select="normalize-space($relTo)"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>

      <xsl:sequence select="distinct-values(util:tokenize($expandedTetras))[. != 'USA']"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:createCountryHash"
                 as="item()*">
      <xsl:param name="relToStrings" as="xs:string*"/>

      <xsl:for-each-group select="$relToStrings" group-by=".">
         <xsl:sequence select="current-grouping-key(), count(current-group())"/>
      </xsl:for-each-group>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:calculateCommonCountries"
                 as="xs:string*">
      <xsl:param name="portionCountryStrings" as="xs:string*"/>

      
      <xsl:variable name="countryHash"
                    select="util:createCountryHash($portionCountryStrings)"/>

      
      <xsl:variable name="expandedTetras"
                    select="util:expandAllTetras($countryHash[position() mod 2 = 1])"/>
      <xsl:variable name="distinctCountryTokens"
                    select="distinct-values(util:tokenize(util:join($expandedTetras)))[. != 'USA']"/>

      
      <xsl:sequence select="$distinctCountryTokens[util:countIn(., $expandedTetras, $countryHash) = $countFdrPortions]"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:decomposeTetragraphs"
                 as="xs:string*">
      <xsl:param name="releasableTo" as="xs:string"/>
      <xsl:value-of select="             for $token in tokenize(normalize-space($releasableTo), ' ')             return                if (util:isTetragraph($token)) then                   util:getTetragraphMembership($token)                else                   $token"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:isTetragraph"
                 as="xs:boolean">
      <xsl:param name="value" as="xs:string"/>

      <xsl:value-of select="             some $token in $tetragraphList                satisfies $token = $value"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:containsSpecialTetra"
                 as="xs:boolean">
      <xsl:param name="releasableTo" as="xs:string"/>
      
      <xsl:value-of select="             some $token in tokenize(normalize-space($releasableTo), ' ')                satisfies util:isTetragraph($token) and $catt//catt:Tetragraph[catt:TetraToken = $token]/@decomposable[not(. = 'Yes' or . = 'Maybe')]"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:containsMaybeTetra"
                 as="xs:boolean">
      <xsl:param name="releasableTo" as="xs:string"/>
      <xsl:value-of select="             some $token in tokenize(normalize-space($releasableTo), ' ')                satisfies util:isTetragraph($token) and $catt//catt:Tetragraph[catt:TetraToken = $token]/@decomposable[. = 'Maybe']"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:relToContainsMaybeTetra"
                 as="xs:boolean">
      <xsl:param name="bannerRelTo" as="xs:string"/>
      <xsl:param name="remainingPartTags" as="node()*"/>

      <xsl:variable name="portion" select="$remainingPartTags[1]"/>

      <xsl:choose>
         <xsl:when test="count($remainingPartTags) = 0">
            
            <xsl:value-of select="false()"/>
         </xsl:when>
         <xsl:when test="$bannerRelTo and util:containsMaybeTetra($bannerRelTo)">
            <xsl:value-of select="true()"/>
         </xsl:when>
         <xsl:when test="$portion/@ism:releasableTo and util:containsMaybeTetra($portion/@ism:releasableTo)">
            <xsl:value-of select="true()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="util:relToContainsMaybeTetraHelper($bannerRelTo, subsequence($remainingPartTags, 2))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:relToContainsMaybeTetraHelper"
                 as="xs:string*">
      <xsl:param name="bannerRelTo" as="xs:string"/>
      <xsl:param name="remainingPartTags" as="node()*"/>

      <xsl:variable name="portion" select="$remainingPartTags[1]"/>

      <xsl:choose>
         <xsl:when test="count($remainingPartTags) = 1">
            
            <xsl:value-of select="util:relToContainsMaybeTetra($bannerRelTo, ())"/>
         </xsl:when>
         <xsl:otherwise>
            
            <xsl:value-of select="util:relToContainsMaybeTetra($bannerRelTo, subsequence($remainingPartTags, 2))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:displayToContainsMaybeTetra"
                 as="xs:boolean">
      <xsl:param name="bannerDisplayTo" as="xs:string"/>
      <xsl:param name="remainingPartTags" as="node()*"/>

      <xsl:variable name="portion" select="$remainingPartTags[1]"/>

      <xsl:choose>
         <xsl:when test="count($remainingPartTags) = 0">
            
            <xsl:value-of select="false()"/>
         </xsl:when>
         <xsl:when test="$bannerDisplayTo and util:containsMaybeTetra($bannerDisplayTo)">
            <xsl:value-of select="true()"/>
         </xsl:when>
         <xsl:when test="$portion/@ism:displayOnlyTo and util:containsMaybeTetra($portion/@ism:displayOnlyTo)">
            <xsl:value-of select="true()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="util:displayToContainsMaybeTetra($bannerDisplayTo, subsequence($remainingPartTags, 2))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:displayToContainsMaybeTetraHelper"
                 as="xs:string*">
      <xsl:param name="bannerDisplayTo" as="xs:string"/>
      <xsl:param name="remainingPartTags" as="node()*"/>

      <xsl:variable name="portion" select="$remainingPartTags[1]"/>

      <xsl:choose>
         <xsl:when test="count($remainingPartTags) = 1">
            
            <xsl:value-of select="util:displayToContainsMaybeTetra($bannerDisplayTo, ())"/>
         </xsl:when>
         <xsl:otherwise>
            
            <xsl:value-of select="util:displayToContainsMaybeTetra($bannerDisplayTo, subsequence($remainingPartTags, 2))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:bannerIsSubset"
                 as="xs:boolean">
      <xsl:param name="bannerRelTo" as="xs:string"/>
      <xsl:param name="portionRelTo" as="xs:string"/>
      <xsl:variable name="bannerRelToDecomposed"
                    select="tokenize(normalize-space(util:decomposeTetragraphs($bannerRelTo)), ' ')"/>
      <xsl:variable name="portionRelToDecomposed"
                    select="tokenize(normalize-space(util:decomposeTetragraphs($portionRelTo)), ' ')"/>
      <xsl:value-of select="             util:containsSpecialTetra($bannerRelTo) or (every $bannerToken in $bannerRelToDecomposed                satisfies (some $portionToken in $portionRelToDecomposed                   satisfies if ($bannerToken = 'USA') then                      true()                   else                      $bannerToken = $portionToken))"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:containsFDR"
                 as="xs:boolean">
      <xsl:param name="elementNode" as="node()"/>
      <xsl:value-of select="$elementNode/@ism:releasableTo or $elementNode/@ism:displayOnlyTo or util:containsAnyOfTheTokens($elementNode/@ism:disseminationControls, ('NF', 'RELIDO')) or util:containsAnyOfTheTokens($elementNode/@ism:nonICmarkings, ('LES-NF', 'SBU-NF'))"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:intersectionOfCountries"
                 as="xs:string*">
      <xsl:param name="commonCountries" as="xs:string"/>
      <xsl:param name="portionRelTo" as="xs:string"/>
      <xsl:variable name="portionRelToDecomposed"
                    select="tokenize(normalize-space(util:decomposeTetragraphs($portionRelTo)), ' ')"/>
      <xsl:value-of select="             for $token in tokenize(normalize-space($commonCountries), ' ')             return                if ($token = $portionRelToDecomposed and not($token = 'USA')) then                   $token                else                   ()"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:recursivelyCheckRelTo"
                 as="xs:string*">
      <xsl:param name="bannerRelTo" as="xs:string"/>
      <xsl:param name="commonCountries" as="xs:string"/>
      <xsl:param name="remainingPartTags" as="node()*"/>

      <xsl:variable name="portion" select="$remainingPartTags[1]"/>

      <xsl:choose>
         <xsl:when test="count(tokenize($commonCountries, ' ')) = 0">
            
            <xsl:value-of select="()"/>
         </xsl:when>
         <xsl:when test="count($remainingPartTags) = 0">
            
            <xsl:value-of select="$commonCountries"/>
         </xsl:when>
         <xsl:when test="not(util:containsFDR($portion)) and $portion/@ism:classification = 'U'">
            
            <xsl:value-of select="util:recursivelyCheckRelTo($bannerRelTo, $commonCountries, subsequence($remainingPartTags, 2))"/>
         </xsl:when>
         <xsl:when test="not($portion/@ism:releasableTo)">
            
            <xsl:value-of select="()"/>
         </xsl:when>
         <xsl:when test="util:containsSpecialTetra($portion/@ism:releasableTo)">
            
            <xsl:value-of select="util:recursivelyCheckRelTo($bannerRelTo, $commonCountries, subsequence($remainingPartTags, 2))"/>
         </xsl:when>
         <xsl:otherwise>
            
            <xsl:choose>
               <xsl:when test="util:bannerIsSubset($bannerRelTo, $portion/@ism:releasableTo)">
                  
                  <xsl:value-of select="util:recursivelyCheckRelToRecurseHelper($bannerRelTo, $commonCountries, $remainingPartTags)"/>
               </xsl:when>
               <xsl:otherwise>
                  
                  <xsl:value-of select="('BANNER_NOT_A_SUBSET_OF_A_PORTION')"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:recursivelyCheckRelToRecurseHelper"
                 as="xs:string*">
      <xsl:param name="bannerRelTo" as="xs:string"/>
      <xsl:param name="commonCountries" as="xs:string"/>
      <xsl:param name="remainingPartTags" as="node()*"/>

      <xsl:variable name="portion" select="$remainingPartTags[1]"/>

      <xsl:choose>
         <xsl:when test="count($remainingPartTags) = 1">
            
            <xsl:value-of select="util:recursivelyCheckRelTo($bannerRelTo, util:intersectionOfCountries($commonCountries, $portion/@ism:releasableTo), ())"/>
         </xsl:when>
         <xsl:otherwise>
            
            <xsl:value-of select="util:recursivelyCheckRelTo($bannerRelTo, util:intersectionOfCountries($commonCountries, $portion/@ism:releasableTo), subsequence($remainingPartTags, 2))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:isUncaveatedAndNoFDR"
                 as="xs:boolean">
      <xsl:param name="element"/>
      <xsl:value-of select="not($element/@ism:disseminationControls) and not($element/@ism:SCIcontrols) and not($element/@ism:nonICmarkings) and not($element/@ism:atomicEnergyMarkings) and not($element/@ism:FGIsourceOpen) and not($element/@ism:FGIsourceProtected) and not($element/@ism:nonUSControls) and not($element/@ism:SARIdentifier)"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:checkRelToPortionsAgainstBannerAndGetCommonCountries"
                 as="xs:string*">
      <xsl:param name="bannerRelTo" as="xs:string"/>
      <xsl:param name="remainingPartTags" as="node()*"/>

      <xsl:variable name="portion" select="$remainingPartTags[1]"/>

      <xsl:choose>
         <xsl:when test="count($remainingPartTags) = 0">
            
            <xsl:value-of select="('PASS')"/>
         </xsl:when>
         <xsl:when test="util:containsFDR($portion) and not($portion/@ism:releasableTo)">
            

            <xsl:value-of select="()"/>
         </xsl:when>
         <xsl:when test="$portion/@ism:releasableTo and not(util:containsSpecialTetra($portion/@ism:releasableTo))">
            
            <xsl:value-of select="util:recursivelyCheckRelTo($bannerRelTo, util:decomposeTetragraphs($portion/@ism:releasableTo), $remainingPartTags)"/>

         </xsl:when>
         <xsl:otherwise>
            
            <xsl:value-of select="util:checkRelToPortionsAgainstBannerAndGetCommonCountries($bannerRelTo, subsequence($remainingPartTags, 2))"/>

         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:getDisplayToCountries">
      <xsl:param name="portion" as="node()"/>
      <xsl:value-of select="normalize-space(concat(normalize-space(string($portion/@ism:releasableTo)), ' ', normalize-space(string($portion/@ism:displayOnlyTo))))"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:isDisplayable"
                 as="xs:boolean">
      <xsl:param name="portion" as="node()"/>
      <xsl:value-of select="$portion/@ism:releasableTo or $portion/@ism:displayOnlyTo"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:recursivelyCheckDisplayTo"
                 as="xs:string*">
      <xsl:param name="bannerRelToAndDisplayTo" as="xs:string"/>
      <xsl:param name="commonCountries" as="xs:string"/>
      <xsl:param name="remainingPartTags" as="node()*"/>

      <xsl:variable name="portion" select="$remainingPartTags[1]"/>

      <xsl:choose>
         <xsl:when test="count(tokenize($commonCountries, ' ')) = 0">
            
            <xsl:value-of select="()"/>
         </xsl:when>
         <xsl:when test="count($remainingPartTags) = 0">
            
            <xsl:value-of select="$commonCountries"/>
         </xsl:when>
         <xsl:when test="not(util:containsFDR($portion)) and $portion/@ism:classification = 'U'">
            
            <xsl:value-of select="util:recursivelyCheckDisplayTo($bannerRelToAndDisplayTo, $commonCountries, subsequence($remainingPartTags, 2))"/>
         </xsl:when>
         <xsl:when test="not($portion/@ism:releasableTo) and not($portion/@ism:displayOnlyTo)">
            
            <xsl:value-of select="()"/>
         </xsl:when>
         <xsl:when test="util:containsSpecialTetra(util:getDisplayToCountries($portion))">
            
            <xsl:value-of select="util:recursivelyCheckDisplayTo($bannerRelToAndDisplayTo, $commonCountries, subsequence($remainingPartTags, 2))"/>
         </xsl:when>
         <xsl:otherwise>
            
            <xsl:choose>
               <xsl:when test="util:bannerIsSubset($bannerRelToAndDisplayTo, util:getDisplayToCountries($portion))">
                  
                  <xsl:value-of select="util:recursivelyCheckDisplayToRecurseHelper($bannerRelToAndDisplayTo, $commonCountries, $remainingPartTags)"/>
               </xsl:when>
               <xsl:otherwise>
                  
                  <xsl:value-of select="('BANNER_NOT_A_SUBSET_OF_A_PORTION')"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:recursivelyCheckDisplayToRecurseHelper"
                 as="xs:string*">
      <xsl:param name="bannerRelToAndDisplayTo" as="xs:string"/>
      <xsl:param name="commonCountries" as="xs:string"/>
      <xsl:param name="remainingPartTags" as="node()*"/>

      <xsl:variable name="portion" select="$remainingPartTags[1]"/>

      <xsl:choose>
         <xsl:when test="count($remainingPartTags) = 1">
            
            <xsl:value-of select="util:recursivelyCheckDisplayTo($bannerRelToAndDisplayTo, util:intersectionOfCountries($commonCountries, util:getDisplayToCountries($portion)), ())"/>
         </xsl:when>
         <xsl:otherwise>
            
            <xsl:value-of select="util:recursivelyCheckDisplayTo($bannerRelToAndDisplayTo, util:intersectionOfCountries($commonCountries, util:getDisplayToCountries($portion)), subsequence($remainingPartTags, 2))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:checkDisplayToPortionsAgainstBannerAndGetCommonCountries"
                 as="xs:string*">
      <xsl:param name="bannerRelToAndDisplayTo" as="xs:string"/>
      <xsl:param name="remainingPartTags" as="node()*"/>

      <xsl:variable name="portion" select="$remainingPartTags[1]"/>

      <xsl:choose>
         <xsl:when test="count($remainingPartTags) = 0">
            
            <xsl:value-of select="('PASS')"/>
         </xsl:when>
         <xsl:when test="util:containsFDR($portion) and not(util:isDisplayable($portion))">
            
            <xsl:value-of select="()"/>
         </xsl:when>
         <xsl:when test="util:isDisplayable($portion) and not(util:containsSpecialTetra(util:getDisplayToCountries($portion)))">
            
            <xsl:value-of select="util:recursivelyCheckDisplayTo($bannerRelToAndDisplayTo, util:decomposeTetragraphs(util:getDisplayToCountries($portion)), $remainingPartTags)"/>
         </xsl:when>
         <xsl:otherwise>
            
            <xsl:value-of select="util:checkDisplayToPortionsAgainstBannerAndGetCommonCountries($bannerRelToAndDisplayTo, subsequence($remainingPartTags, 2))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:getTetragraphMembership">
      <xsl:param name="tetra"/>

      <xsl:value-of select="             if ($catt//catt:Tetragraph[@decomposable = 'Yes']) then                tokenize(string-join((for $country in $catt//catt:Tetragraph[catt:TetraToken = $tetra]/catt:Membership/*/text()                return                   $country), ' '), ' ')             else                $tetra"/>
   </xsl:function>
   <xsl:function xmlns:sch="http://purl.oclc.org/dsdl/schematron"
                 name="util:getTetragraphReleasability">
      <xsl:param name="tetra"/>

      <xsl:value-of select="             distinct-values(for $token in tokenize($catt//catt:Tetragraph[catt:TetraToken = $tetra]/@ism:releasableTo, ' ')             return                if (index-of($catt//catt:TetraToken, $token) &gt; 0) then                   util:getTetragraphMembership($token)                else                   $token)"/>
   </xsl:function>

   <!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-select-full-path">
      <xsl:apply-templates select="." mode="schematron-get-full-path"/>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">
            <xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>*:</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>[namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding"
                    select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])"/>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="1+ $preceding"/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="@*" mode="schematron-get-full-path">
      <xsl:apply-templates select="parent::*" mode="schematron-get-full-path"/>
      <xsl:text>/</xsl:text>
      <xsl:choose>
         <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@*[local-name()='</xsl:text>
            <xsl:value-of select="local-name()"/>
            <xsl:text>' and namespace-uri()='</xsl:text>
            <xsl:value-of select="namespace-uri()"/>
            <xsl:text>']</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>

   <!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>
   <!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
      <xsl:for-each select="ancestor-or-self::*">
         <xsl:text>/</xsl:text>
         <xsl:value-of select="name(.)"/>
         <xsl:if test="parent::*">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1"/>
            <xsl:text>]</xsl:text>
         </xsl:if>
      </xsl:for-each>
      <xsl:if test="not(self::*)">
         <xsl:text/>/@<xsl:value-of select="name(.)"/>
      </xsl:if>
   </xsl:template>

   <!--MODE: GENERATE-ID-FROM-PATH -->
<xsl:template match="/" mode="generate-id-from-path"/>
   <xsl:template match="text()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')"/>
   </xsl:template>
   <xsl:template match="comment()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')"/>
   </xsl:template>
   <xsl:template match="processing-instruction()" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-from-path">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:value-of select="concat('.@', name())"/>
   </xsl:template>
   <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
      <xsl:apply-templates select="parent::*" mode="generate-id-from-path"/>
      <xsl:text>.</xsl:text>
      <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')"/>
   </xsl:template>

   <!--MODE: GENERATE-ID-2 -->
<xsl:template match="/" mode="generate-id-2">U</xsl:template>
   <xsl:template match="*" mode="generate-id-2" priority="2">
      <xsl:text>U</xsl:text>
      <xsl:number level="multiple" count="*"/>
   </xsl:template>
   <xsl:template match="node()" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>n</xsl:text>
      <xsl:number count="node()"/>
   </xsl:template>
   <xsl:template match="@*" mode="generate-id-2">
      <xsl:text>U.</xsl:text>
      <xsl:number level="multiple" count="*"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="string-length(local-name(.))"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="translate(name(),':','.')"/>
   </xsl:template>
   <!--Strip characters--><xsl:template match="text()" priority="-1"/>

   <!--SCHEMA SETUP-->
<xsl:template match="/">
      <svrl:schematron-output xmlns:svrl="http://purl.oclc.org/dsdl/svrl" title="" schemaVersion="">
         <xsl:comment>
            <xsl:value-of select="$archiveDirParameter"/>   
		 <xsl:value-of select="$archiveNameParameter"/>  
		 <xsl:value-of select="$fileNameParameter"/>  
		 <xsl:value-of select="$fileDirParameter"/>
         </xsl:comment>
         <svrl:text>This is the root file for the ISM Schematron rule set. It loads all of
      the required CVEs declares some variables and includes all of the Rule .sch files. </svrl:text>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ism" prefix="ism"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ntk" prefix="ntk"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:taxonomy:catt:tetragraph" prefix="catt"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:cve" prefix="cve"/>
         <svrl:ns-prefix-in-attribute-values uri="deprecated:value:function" prefix="dvf"/>
         <svrl:ns-prefix-in-attribute-values uri="urn:us:gov:ic:ism:xsl:util" prefix="util"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">typeConstraintPatterns</xsl:attribute>
            <xsl:attribute name="name">typeConstraintPatterns</xsl:attribute>
            <svrl:text>Collection of global variables for use in other Schematron rules.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M7"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00155</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00155</xsl:attribute>
            <svrl:text>
        [ISM-ID-00155][Error] If ISM_USDOD_RESOURCE and 
        1. not ISM_DOD_DISTRO_EXEMPT
        AND
        2. Attribute noticeType of ISM_RESOURCE_ELEMENT does not contain one of 
        [DoD-Dist-A], [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X]
        
        Human Readable: All US DOD documents that do not claim exemption from 
        DoD5230.24 distribution statements must have a distribution statement
        for the entire document.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USDOD_RESOURCE and not ISM_DOD_DISTRO_EXEMPT and
        the current element is the ISM_RESOURCE_ELEMENT, this rule ensures that 
      attribute ism:noticeType is specified with a value containing one of the
      tokens: [DoD-Dist-A], [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D],
      [DoD-Dist-E], [DoD-Dist-F], [DoD-Dist-X].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M156"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00157</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00157</xsl:attribute>
            <svrl:text> [ISM-ID-00157][Error] If ISM_USDOD_RESOURCE and: 
        1. The attribute notice contains one of the [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], or [DoD-Dist-E] 
          AND
        2. The attribute noticeReason is not specified. 
        
        Human Readable: DoD distribution statements B, C, D , or E all require a reason. </svrl:text>
            <svrl:text> If the document is an ISM_USDOD_RESOURCE, for each element which
        specifies attribute ism:noticeType with a value containing the token [DoD-Dist-B],
        [DoD-Dist-C], [DoD-Dist-D], or [DoD-Dist-E], this rule ensures that attribute
        ism:noticeReason is specified. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M157"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00158</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00158</xsl:attribute>
            <svrl:text>
        [ISM-ID-00158][Error] If ISM_USDOD_RESOURCE and:
            1. not ISM_DOD_DISTRO_EXEMPT AND
            2. attribute classification of ISM_RESOURCE_ELEMENT is not [U] AND
            3. A resource attribute notice does not contain one of [DoD-Dist-B], [DoD-Dist-C],
        [DoD-Dist-D], [DoD-Dist-E], or [DoD-Dist-F].
        
        Human Readable: All classified DOD documents that do not claim
        exemption from DoD5230.24 distribution statements must use one
        of DoD distribution statements B, C, D, E, or F.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USDOD_RESOURCE and not ISM_DOD_DISTRO_EXEMPT and
        the attribute classification of ISM_RESOURCE_ELEMENT is not [U], then this rule ensures that the
        resource element specifies attribute ism:noticeType with a value containing the token
        [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], or [DoD-Dist-F].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M158"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00161</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00161</xsl:attribute>
            <svrl:text>
        [ISM-ID-00161][Error] If the document is an
        1. ISM_USDOD_RESOURCE AND
        2. the attribute notice of ISM_RESOURCE_ELEMENT contains [DoD-Dist-A] AND
        3. no portions in the document have their attribute excludeFromRollup set to [true]
        THEN there must not be any attribute nonICmarkings present.
        
        Human Readable: Distribution statement A (Public Release) is 
        incompatible with any nonICMarkings if excludeFromRollup is not TRUE.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USDOD_RESOURCE and @ism:noticeType contains 'DoD-Dist-A' 
        and no portions in the document have their @ism:excludeFromRollup set to true, 
        then there must not be any @ism:nonICMarkings present.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M159"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00162</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00162</xsl:attribute>
            <svrl:text>
        [ISM-ID-00162][Error] If ISM_USDOD_RESOURCE and 
        1. not ISM_DOD_DISTRO_EXEMPT
        AND
        2. Attribute noticeType of ISM_RESOURCE_ELEMENT contains more than one of 
        [DoD-Dist-A], [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X]
        
        Human Readable: All US DOD documents that do not claim exemption from 
        DoD5230.24 distribution statements must have only 1 distribution statement
        for the entire document.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_USDOD_RESOURCE and not ISM_DOD_DISTRO_EXEMPT, and
      the current element is the ISM_RESOURCE_ELEMENT, this rule ensures that
      attribute noticeType is specified with a value containing only one of 
      [DoD-Dist-A], [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], 
      [DoD-Dist-F], or [DoD-Dist-X].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M160"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00227</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00227</xsl:attribute>
            <svrl:text>
        [ISM-ID-00227][Error] Attribute @noticeType may only appear on the 
        resource node when it contains the values [DoD-Dist-A], [DoD-Dist-B], 
        [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X].
        
        Human Readable: Documents may only specify a document-level notice if
        it pertains to DoD Distribution.
    </svrl:text>
            <svrl:text>
        For every resource element with the ism:noticeType attribute specified,
        this rule ensures that attribute's value is one of [DoD-Dist-A], [DoD-Dist-B], 
        [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X]
        by using a regular expression.
        
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M161"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00237</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00237</xsl:attribute>
            <svrl:text>
        [ISM-ID-00237][Error] If ISM_USDOD_RESOURCE, any element which specifies
        attribute noticeType containing one of the tokens [DoD-Dist-B], 
       	[DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X]
       	must also specify attribute noticeDate.
       	
        Human Readable: DoD distribution statements B, C, D ,E ,F, and X all require a date.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM_USGOV_RESOURCE, for each element which has 
    	attribute ism:noticeType specified with a value containing the token
        [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], 
        or [DoD-Dist-X], this rule ensures that attribute ism:noticeDate is specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M162"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00238</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00238</xsl:attribute>
            <svrl:text>
    	[ISM-ID-00238][Error] If ISM_USDOD_RESOURCE, if any element specifies
    	attribute noticeType containing one of the tokens [DoD-Dist-B], 
    	[DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X],
    	then an element in the document must specify attribute pocType with
    	the same value as attribute noticeType.
    	
        Human Readable: DoD distribution statements B, C, D ,E ,F, and X all 
        require a corresponding point of contact.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM_USDOD_RESOURCE, for each element which has 
    	attribute ism:noticeType specified with a value containing the token
        [DoD-Dist-B], [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], 
        or [DoD-Dist-X], this rule ensures that some element in the document 
        specifies attribute ism:pocType with the same value as ism:noticeType.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M163"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00239</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00239</xsl:attribute>
            <svrl:text>
		[ISM-ID-00239][Error] If ISM_USDOD_RESOURCE and attribute noticeType of
		ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], then any element 
		which contributes to rollup should not have an attribute
		@disseminationControls present.
		
		Human Readable: Distribution statement A (Public Release) is incompatible 
		with @disseminationControls present for contributing portions.
	</svrl:text>
            <svrl:text>
		If the document is an ISM_USDOD_RESOURCE and the attribute
		noticeType of ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], for
		each element which specifies attribute ism:disseminationControls 
		this rule ensures that attribute ism:disseminationControls is not present.
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M164"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00240</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00240</xsl:attribute>
            <svrl:text>
        [ISM-ID-00240][Error] If ISM_USDOD_RESOURCE and attribute noticeType of
        ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], then any element
        which contributes to rollup should not have an attribute
        @atomicEnergyMarkings present.
        
        Human Readable: Distribution statement A (Public Release) is incompatible 
        with @atomicEnergyMarkings.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM_USDOD_RESOURCE and the attribute
    	noticeType of ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], for
    	each element which specifies attribute ism:atomicEnergyMarkings this rule ensures that attribute 
    	ism:atomicEnergyMarkings is not present.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M165"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00014</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00014</xsl:attribute>
            <svrl:text>
        [ISM-ID-00014][Error] If ISM_NSI_EO_APPLIES then one or more of the following 
        attributes: declassDate, declassEvent, or declassException must be specified on the ISM_RESOURCE_ELEMENT.
        
        Human Readable: Documents under E.O. 13526 must have declassification instructions included in the 
        classification authority block information.
    </svrl:text>
            <svrl:text>
        If ISM_NSI_EO_APPLIES, this rule ensures that the ISM_RESOURCE_ELEMENT specifies
      one of the following attributes: ism:declassDate, ism:declassEvent, ism:declassException.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M166"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00016</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00016</xsl:attribute>
            <svrl:text>
        [ISM-ID-00016][Error] If ISM_USGOV_RESOURCE and attribute 
        classification has a value of [U], then attributes classificationReason,
        classifiedBy, derivativelyClassifiedBy, declassDate, declassEvent, 
        declassException, derivedFrom, SARIdentifier, or 
        SCIcontrols must not be specified.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM_USGOV_RESOURCE, for each element which has 
    	attribute ism:classification specified with a value of [U] this rule ensures that NONE of the following attributes are specified:
    	ism:classifiedBy, ism:declassDate, ism:declassEvent, ism:declassException,
    	ism:derivativelyClassifiedBy, ism:derivedFrom, 
    	ism:SARIdentifier, or ism:SCIcontrols. 
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M167"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00017</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00017</xsl:attribute>
            <svrl:text>
        [ISM-ID-00017][Error] If ISM_NSI_EO_APPLIES and attribute 
        classifiedBy is specified, then attribute classificationReason must 
        be specified. 
        
        Human Readable: Documents under E.O. 13526 containing 
        Originally Classified data require a classification reason to be
        identified.
    </svrl:text>
            <svrl:text>
    	If ISM_NSI_EO_APPLIES, for each element which specifies attribute
    	ism:classifiedBy, this rule ensures that attribute ism:classificationReason
    	is specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M168"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00026</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00026</xsl:attribute>
            <svrl:text>To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M169"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00028</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00028</xsl:attribute>
            <svrl:text>
      [ISM-ID-00028][Error] If ISM_USGOV_RESOURCE and attribute 
      disseminationControls contains the name token [OC] or [EYES],
      then attribute classification must have a value of [TS], [S], or [C].
      
      Human Readable: Portions marked for ORCON or EYES ONLY dissemination 
      in a USA document must be CONFIDENTIAL, SECRET, or TOP SECRET.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [OC] or [EYES] this rule ensures that attribute
    	ism:classification is specified with a value of [C], [S], or [TS].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M170"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00030</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00030</xsl:attribute>
            <svrl:text>
        [ISM-ID-00030][Error] If ISM_USGOV_RESOURCE and attribute 
        disseminationControls contains the name token [FOUO], then attribute
        classification must have a value of [U].
        
        Human Readable: Portions marked for FOUO dissemination in a USA document
        must be classified UNCLASSIFIED.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [FOUO] this rule ensures that attribute ism:classification is 
    	specified with a value of [U].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M171"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00031</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00031</xsl:attribute>
            <svrl:text>
        [ISM-ID-00031][Error] If ISM_USGOV_RESOURCE and attribute 
        disseminationControls contains the name token [REL] or [EYES], then 
        attribute releasableTo must be specified.
        
        Human Readable: USA documents containing REL TO or EYES ONLY 
        dissemination must specify to which countries the document is releasable.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [REL] or [EYES] this rule ensures that attribute ism:releasableTo
    	is specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M172"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00032</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00032</xsl:attribute>
            <svrl:text>
        [ISM-ID-00032][Error] If ISM_USGOV_RESOURCE and attribute 
        disseminationControls is not specified, or is specified and does not 
        contain the name token [REL] or [EYES], then attribute releasableTo 
        must not be specified.
        
        Human Readable: USA documents must only specify to which countries it is 
        authorized for release if dissemination information contains 
        REL TO or EYES ONLY data. 
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        does not specify attribute disseminationControls or specifies attribute
        ism:disseminationControls with a value containing the token 
        [REL] or [EYES] this rule ensures that attribute ism:releasableTo is not 
        specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M173"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00033</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00033</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that mutually exclusive tokens do not exist in
		an attribute. The calling rule must pass @ism:disseminationControls and ('REL', 'EYES', 'NF').</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M174"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00035</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00035</xsl:attribute>
            <svrl:text>
    For values that contributed to rollup, the values are ordered according to its CVE
    
    To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order.
    
    For values that do not contribute to rollup, the values are ordered alphabetically
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M175"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00037</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00037</xsl:attribute>
            <svrl:text>[ISM-ID-00037][Error] When ISM_USGOV_RESOURCE and @ism:nonICmarkings
        contains [SBU] or [SBU-NF] then @ism:classification must equal [U]. </svrl:text>
            <svrl:text>Human Readable: SBU and SBU-NF data must be marked
        UNCLASSIFIED on the banner in USA documents.</svrl:text>
            <svrl:text>For a resource element (@ism:resourceElement="true"), if
        @ism:compliesWith contains ‘USGov’ and @ism:nonICmarkings contains [SBU] or [SBU-NF] then
        @ism:classification must equal [U].</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M176"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00038</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00038</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that mutually exclusive tokens do not exist in
		an attribute. The calling rule must pass @ism:nonICmarkings and ('XD', 'ND', 'SBU', 'SBU-NF').</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M177"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00040</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00040</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list. The calling rule must pass *[$ISM_USGOV_RESOURCE                                      and util:containsAnyOfTheTokens(@ism:ownerProducer, ('USA'))], @ism:classification, $classificationUSList, '   [ISM-ID-00040][Error] If ISM_USGOV_RESOURCE and attribute    ownerProducer contains [USA] then attribute classification must have a   value in CVEnumISMClassificationUS.xml.   '.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M178"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00041</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00041</xsl:attribute>
            <svrl:text>To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M179"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00042</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00042</xsl:attribute>
            <svrl:text>
    For values that contributed to rollup, the values are ordered according to its CVE
    
    To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order.
    
    For values that do not contribute to rollup, the values are ordered alphabetically
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M180"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00043</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00043</xsl:attribute>
            <svrl:text>
        [ISM-ID-00043][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols
        contains the name token [SI], then attribute classification must have
        a value of [TS], [S], or [C].
        
        Human Readable: A USA document containing Special Intelligence (SI) 
        data must be classified CONFIDENTIAL, SECRET, or TOP SECRET.  
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [SI] this rule ensures that attribute ism:classification is specified with
        a value containing the token [TS], [S], or [C].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M181"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00044</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00044</xsl:attribute>
            <svrl:text> [ISM-ID-00044][Error] If the document is an ISM_USGOV_RESOURCE and the
        attribute SCIcontrols contain a name token with [SI-G], then the attribute classification
        must have a value of [TS]. 
        
        Human Readable: A USA document containing Special Intelligence (SI) GAMMA compartment data 
        must be classified TOP SECRET. </svrl:text>
            <svrl:text> If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing a token with [SI-G] this rule
        ensures that attribute ism:classification is specified with a value containing the token
        [TS]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M182"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00045</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00045</xsl:attribute>
            <svrl:text>
        [ISM-ID-00045][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols
        contains a name token starting with [SI-G], then attribute
        disseminationControls must contain the name token [OC].
        
        Human Readable: A USA document containing Special Intelligence (SI)
        GAMMA compartment data must be marked for ORIGINATOR CONTROLLED 
        dissemination.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing a token
        starting with [SI-G] this rule ensures that attribute
        ism:disseminationControls is specified with a value containing the
        token [OC].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M183"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00047</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00047</xsl:attribute>
            <svrl:text>
        [ISM-ID-00047][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols
        contains the name token [TK], then attribute classification must have
        a value of [TS] or [S].
        
        Human Readable: A USA document containing TALENT KEYHOLE data must
        be classified SECRET or TOP SECRET.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [TK] this rule ensures that attribute ism:classification is 
        specified with a value containing the token [TS] or [S].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M184"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00048</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00048</xsl:attribute>
            <svrl:text>
        [ISM-ID-00048][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols
        contains the name token [HCS], then attribute classification must have
        a value of [TS], [S], or [C].
        
        Human Readable: A USA document containing HCS data must be classified
        CONFIDENTIAL, SECRET, or TOP SECRET.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [HCS] this rule ensures that attribute ism:classification is 
        specified with a value containing the token [TS], [S], or [C].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M185"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00049</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00049</xsl:attribute>
            <svrl:text>
        [ISM-ID-00049][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols
        contains the name token [HCS], then attribute disseminationControls
        must contain the name token [NF].
        
        Human Readable: A USA document containing HCS data must be marked
        for NO FOREIGN dissemination.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [HCS] this rule ensures that attribute ism:disseminationControls is 
        specified with a value containing the token [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M186"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00056</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00056</xsl:attribute>
            <svrl:text> [ISM-ID-00056][Error] If the document is an ISM_USGOV_RESOURCE and
        attribute classification of ISM_RESOURCE_ELEMENT has a value of [U] then no element meeting
        ISM_CONTRIBUTES in the document may have a classification attribute of [C], [S], [TS], or [R]. 
        
        Human Readable: USA UNCLASSIFIED documents can't have portion markings with the
        classification TOP SECRET, SECRET, CONFIDENTIAL, or RESTRICTED data. </svrl:text>
            <svrl:text> If the document is an ISM_USGOV_RESOURCE and attribute
        ism:classification on $ISM_RESOURCE_ELEMENT has a value of [U], this rule ensures that no
        element meeting ISM_CONTRIBUTES has attribute ism:classification with value [C], [S], [TS],
        [R]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M187"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00058</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00058</xsl:attribute>
            <svrl:text>
        [ISM-ID-00058][Error] If ISM_USGOV_RESOURCE and attribute classification of ISM_RESOURCE_ELEMENT 
        has a value of [C] then no element meeting ISM_CONTRIBUTES_USA in the document may have a classification attribute of [S] or [TS].
        
        Human Readable: USA CONFIDENTIAL documents can't have TOP SECRET or SECRET data.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_USGOV_RESOURCE and attribute ism:classification
      on $ISM_RESOURCE_ELEMENT has a value of [C], this rule ensures that
      no element meeting ISM_CONTRIBUTES_USA has attribute ism:classification with
      value [S], [TS]. 
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M188"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00059</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00059</xsl:attribute>
            <svrl:text>
        [ISM-ID-00059][Error] If ISM_USGOV_RESOURCE and attribute classification of ISM_RESOURCE_ELEMENT 
        has a value of [S] then no element meeting ISM_CONTRIBUTES_USA in the document may have a classification attribute of [TS].
        
        Human Readable: USA SECRET documents can't have TOP SECRET data.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_USGOV_RESOURCE and attribute ism:classification
      on $ISM_RESOURCE_ELEMENT has a value of [S], this rule ensures that
      no element meeting ISM_CONTRIBUTES_USA has attribute ism:classification with
      value [TS].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M189"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00064</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00064</xsl:attribute>
            <svrl:text> [ISM-ID-00064][Error] If ISM_USGOV_RESOURCE and any element meeting
        ISM_CONTRIBUTES in the document have the attribute FGIsourceOpen containing any value then
        the ISM_RESOURCE_ELEMENT must have either FGIsourceOpen or FGIsourceProtected with a value.
        Human Readable: USA documents having FGI Open data must have FGI Open or FGI Protected at
        the resource level. </svrl:text>
            <svrl:text> If IC Markings System Register and Manual marking rules do not apply to the document then this
        rule does not apply and this rule returns true. If the current element has attribute FGIsourceOpen
        specified and does not have attribute excludeFromRollup set to true, this rule ensures that
        the resourceElement has one of the following attributes specified: FGIsourceOpen or
        FGIsourceProtected. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M190"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00065</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00065</xsl:attribute>
            <svrl:text>
        [ISM-ID-00065][Error] If ISM_USGOV_RESOURCE and any element meeting ISM_CONTRIBUTES in the document 
        have the attribute FGIsourceProtected containing any value then the ISM_RESOURCE_ELEMENT must have FGIsourceProtected with a value.
        
        Human Readable: USA documents having FGI Protected data must have FGI Protected at the resource level.
    </svrl:text>
            <svrl:text>
        If IC Markings System Register and Manual rules do not apply to the document then the rule does not apply
        and this rule returns true. If any element has attribute FGIsourceProtected specified 
        with a non-empty value and does not have attribute excludeFromRollup set to true, 
        then this rule ensures that the banner has attribute FGIsourceProtected specified with 
        a non-empty value.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M191"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00066</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00066</xsl:attribute>
            <svrl:text>
        [ISM-ID-00066][Error] If ISM_USGOV_RESOURCE and: 
        1. Any element meeting ISM_CONTRIBUTES in the document has the attribute disseminationControls containing [FOUO]
        AND
        2. ISM_RESOURCE_ELEMENT has the attribute classification [U]
        AND
        3. No element meeting ISM_CONTRIBUTES in the document has nonICmarkings
        AND
        4. Elements meeting ISM_CONTRIBUTES only contain dissemination controls 
        [REL], [RELIDO],[NF], [DISPLAYONLY], [EYES], and [FOUO].
        
        Then the ISM_RESOURCE_ELEMENT must have disseminationControls containing [FOUO].
        
        Human Readable: USA Unclassified documents having FOUO data, no non IC Markings, and only 
        contains dissemination controls [REL], [RELIDO], [NF], [DISPLAYONLY], [EYES], and [FOUO] must have 
        FOUO at the resource level.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, the current element is the ISM_RESOURCE_ELEMENT,
        some element meeting ISM_CONTRIBUTES specifies attribute ism:disseminationControls
        with a value containing [FOUO], the ISM_RESOURCE_ELEMENT specifies the attribute
        ism:classification with a value of [U], no element meeting ISM_CONTRIBUTES
        specifies attribute ism:nonICmarkings, and elements meeting ISM_CONTRIBUTES
        only contain ism:disseminationControls with tokens [REL], [RELIDO], [NF], [DISPLAYONLY], [EYES], and [FOUO], then the resource 
        element must contain ism:disseminationControls with a value containing the
        token [FOUO].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M192"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00067</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00067</xsl:attribute>
            <svrl:text> If the document is an ISM_USGOV_RESOURCE and an element meeting
    ISM_CONTRIBUTES specifies attribute ism:disseminationControls with a value containing the token
    [OC], then this rule ensures that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:disseminationControls with a value containing the token [OC]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M193"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00068</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00068</xsl:attribute>
            <svrl:text> If the document is an ISM_USGOV_RESOURCE and an element meeting
    ISM_CONTRIBUTES specifies attribute ism:disseminationControls with a value containing the token
    [IMC], then this rule ensures that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:disseminationControls with a value containing the token [IMC]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M194"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00070</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00070</xsl:attribute>
            <svrl:text> If the document is an ISM_USGOV_RESOURCE and an element meeting
    ISM_CONTRIBUTES specifies attribute ism:disseminationControls with a value containing the token
    [NF], then this rule ensures that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:disseminationControls with a value containing the token [NF]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M195"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00071</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00071</xsl:attribute>
            <svrl:text> If the document is an ISM_USGOV_RESOURCE and an element meeting
    ISM_CONTRIBUTES specifies attribute ism:disseminationControls with a value containing the token
    [PR], then this rule ensures that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:disseminationControls with a value containing the token [PR]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M196"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00072</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00072</xsl:attribute>
            <svrl:text> If the document is an ISM_USGOV_RESOURCE and an element meeting
    ISM_CONTRIBUTES specifies attribute ism:atomicEnergyMarkings with a value containing the token
    [RD], then this rule ensures that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:atomicEnergyMarkings with a value containing the token [RD]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M197"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00073</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00073</xsl:attribute>
            <svrl:text> If the document is an ISM_USGOV_RESOURCE and an element meeting
    ISM_CONTRIBUTES specifies attribute ism:atomicEnergyMarkings with a value containing the token
    [RD-CNWDI], then this rule ensures that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:atomicEnergyMarkings with a value containing the token [RD-CNWDI]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M198"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00074</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00074</xsl:attribute>
            <svrl:text>
        [ISM-ID-00074][Error] If ISM_USGOV_RESOURCE and any element meeting ISM_CONTRIBUTES 
        in the document has the attribute atomicEnergyMarkings containing [RD-SG-##] then the ISM_RESOURCE_ELEMENT must have 
        atomicEnergyMarkings containing [RD-SG-##]. ## represent digits 1 through 99 the ## must match.
        
        Human Readable: USA documents having Restricted SIGMA-## Data must have the same Restricted SIGMA-## Data at the resource level.
    </svrl:text>
            <svrl:text>
        If IC Markings System Register and Manual rules do not apply to the document then the rule does not apply
        and this rule returns true. This rule ensures that no element that does not have attribute excludeFromRollup 
        set to true has attribute atomicEnergyMarkings specified
        with a value containing [RD-SG-##], where ## is represented by a regular expression matching
        numbers 1 through 99, unless the resourceElement also has attribute
        atomicEnergyMarkings specified with a value containing [RD-SG-##].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M199"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00075</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00075</xsl:attribute>
            <svrl:text>
    If the document is an ISM_USGOV_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:atomicEnergyMarkings with a value containing the token
    [FRD] and the exception value(s) are not present, then this rule ensures that 
    the ISM_RESOURCE_ELEMENT specifies the attribute ism:atomicEnergyMarkings with a 
    value containing the token [FRD].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M200"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00077</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00077</xsl:attribute>
            <svrl:text>
        [ISM-ID-00077][Error] If ISM_USGOV_RESOURCE and any element meeting ISM_CONTRIBUTES in the 
        document has the attribute atomicEnergyMarkings containing [FRD-SG-##] and the ISM_RESOURCE_ELEMENT
        does not have atomicEnergyMarkings containing [RD], then the ISM_RESOURCE_ELEMENT must have 
        atomicEnergyMarkings containing [FRD-SG-##]. ## represent digits 1 through 99 the ## must match.
        
        Human Readable: USA documents having Formerly Restricted SIGMA-## data and not having RD data must have the same Formerly Restricted SIGMA-## Data at 
        the resource level.
    </svrl:text>
            <svrl:text>
        If IC Markings System Register and Manual rules do not apply to the document then the rule does not apply
        and this rule returns true. This rule ensures that no element that does not have attribute excludeFromRollup 
        set to true has attribute atomicEnergyMarkings specified
        with a value containing [FRD-SG-##], where ## is represented by a regular expression matching
        numbers 1 through 99, unless the resourceElement also has attribute
        atomicEnergyMarkings specified with a value containing [FRD-SG-##] or [RD] is specified on the 
        ISM_RESOURCE_ELEMENT.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M201"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00078</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00078</xsl:attribute>
            <svrl:text>
    If the document is an ISM_USGOV_RESOURCE, and the ISM_RESOURCE_ELEMENT 
    specifies attribute ism:classification with a value of 
    U an element meeting ISM_CONTRIBUTES
    specifies attribute ism:atomicEnergyMarkings with a value containing the token
    [DCNI], then this rule ensures that the ISM_RESOURCE_ELEMENT specifies the 
    attribute ism:atomicEnergyMarkings with a value containing the token [DCNI].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M202"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00079</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00079</xsl:attribute>
            <svrl:text>
    If the document is an ISM_USGOV_RESOURCE, and the ISM_RESOURCE_ELEMENT 
    specifies attribute ism:classification with a value of 
    U an element meeting ISM_CONTRIBUTES
    specifies attribute ism:atomicEnergyMarkings with a value containing the token
    [UCNI], then this rule ensures that the ISM_RESOURCE_ELEMENT specifies the 
    attribute ism:atomicEnergyMarkings with a value containing the token [UCNI].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M203"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00080</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00080</xsl:attribute>
            <svrl:text> If the document is an ISM_USGOV_RESOURCE and an element meeting
    ISM_CONTRIBUTES specifies attribute ism:disseminationControls with a value containing the token
    [DSEN], then this rule ensures that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:disseminationControls with a value containing the token [DSEN]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M204"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00081</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00081</xsl:attribute>
            <svrl:text> If the document is an ISM_USGOV_RESOURCE and an element meeting
    ISM_CONTRIBUTES specifies attribute ism:disseminationControls with a value containing the token
    [FISA], then this rule ensures that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:disseminationControls with a value containing the token [FISA]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M205"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00084</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00084</xsl:attribute>
            <svrl:text>
    If the document is an ISM_USGOV_RESOURCE, and the ISM_RESOURCE_ELEMENT 
    specifies attribute ism:classification with a value of 
    U an element meeting ISM_CONTRIBUTES
    specifies attribute ism:nonICmarkings with a value containing the token
    [DS], then this rule ensures that the ISM_RESOURCE_ELEMENT specifies the 
    attribute ism:nonICmarkings with a value containing the token [DS].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M206"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00085</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00085</xsl:attribute>
            <svrl:text>
    If the document is an ISM_USGOV_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:nonICmarkings with a value containing the token
    [XD] and the exception value(s) are not present, then this rule ensures that 
    the ISM_RESOURCE_ELEMENT specifies the attribute ism:nonICmarkings with a 
    value containing the token [XD].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M207"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00086</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00086</xsl:attribute>
            <svrl:text> If the document is an ISM_USGOV_RESOURCE and an element meeting
    ISM_CONTRIBUTES specifies attribute ism:nonICmarkings with a value containing the token
    [ND], then this rule ensures that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:nonICmarkings with a value containing the token [ND]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M208"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00087</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00087</xsl:attribute>
            <svrl:text> [ISM-ID-00087][Error] Classified USA documents having SBU-NF Data must
        have NF at the resource level. </svrl:text>
            <svrl:text> If IC Markings System Register and Manual rules do not apply to the
        document then the rule does not apply and the rule returns true. If any element has
        attribute nonICmarkings specified with a value containing [SBU-NF], does not have attribute
        excludeFromRollup set to true, and the resourceElement has attribute classification
        specified with a value other than [U], this rule ensures that the resourceElement has
        attribute disseminationControls specified with a value containing [NF]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M209"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00088</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00088</xsl:attribute>
            <svrl:text>[ISM-ID-00088][Error] If ISM_USGOV_RESOURCE and releasableTo is specified on the resource
        element then all classified portions must specify releasableTo and all Unclass portions must be REL or contain
        no caveats. Human Readable: USA documents having any classified portion that is not Releasable or having
        unclassified portions with disseminationControls that are not [REL] cannot be REL at the resource level.</svrl:text>
            <svrl:text>If IC Markings System Register and Manual rules apply to the document, this rule verifies
        that all portions either have the attribute classification specified with a value of [U] and uncaveated or REL
        or classified portions of the document have the attribute releasableTo. Attribute releasableTo is only valid on
        an element if attribute disseminationControls is specified with a value containing [REL] or [EYES], as [REL]
        supersedes [EYES] in the banner. If any elements do not meet either of the two requirements stated above, then
        the assertion fails since attribute releasableTo appears on the banner but is not present on all classified
        portions.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M210"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00090</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00090</xsl:attribute>
            <svrl:text>
        [ISM-ID-00090][Error] If ISM_USGOV_RESOURCE and any element: 
        1. Meets ISM_CONTRIBUTES
        AND
        2. Has the attribute disseminationControls containing [REL]
        Then the ISM_RESOURCE_ELEMENT must not have attribute disseminationControls containing [EYES]. 
        
        Human Readable: USA documents with any portion that is REL must not be EYES at the resource level.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_CAPO_RESOURCE, the current element is the 
        ISM_RESOURCE_ELEMENT, and some element meeting ISM_CONTRIBUTES specifies
        attribute ism:disseminationControls with a value containing [REL], this rule ensures that ISM_RESOURCE_ELEMENT does not specify attribute
        ism:disseminationControls or specifies the attribute with a value
        that does not contain the token [EYES].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M211"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00095</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00095</xsl:attribute>
            <svrl:text>To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M212"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00096</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00096</xsl:attribute>
            <svrl:text>To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M213"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00097</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00097</xsl:attribute>
            <svrl:text>
        [ISM-ID-00097][Warning] If ISM_USGOV_RESOURCE and attribute FGIsourceProtected is 
        specified with a value other than [FGI] then the value(s) must not be discoverable in IC shared spaces.
        
        Human Readable: FGI Protected should rarely if ever be seen outside of an agency's internal systems.    
    </svrl:text>
            <svrl:text>
    	If the document is an ISM_USGOV_RESOURCE, for each element which specifies
    	the attribute ism:FGIsourceProtected, this rule ensures that attribute
    	ism:FGIsourceProtected contains only the token [FGI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M214"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00099</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00099</xsl:attribute>
            <svrl:text>
        [ISM-ID-00099][Error] If ISM_USGOV_RESOURCE and attribute ownerProducer
        contains the token [FGI], then the token [FGI] must be the only value 
        in attribute ownerProducer.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribtue ism:ownerProducer with a value containing the token
        [FGI] this rule ensures that attribute ism:ownerProducer only contains a 
        single token.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M215"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00100</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00100</xsl:attribute>
            <svrl:text>To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M216"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00104</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00104</xsl:attribute>
            <svrl:text> [ISM-ID-00104][Error] If the document is an ISM_USGOV_RESOURCE and any
    element in the document is: 
      1. Unclassified and meets ISM_CONTRIBUTES 
        AND 
      2. Has the attribute nonICmarkings containing [SBU-NF] 
        AND
      3. The ISM_RESOURCE_ELEMENT has attribute nonICmarkings does not contain [XD] or [ND] 
        AND
      4. The ISM_RESOURCE_ELEMENT has attribute DisseminationControls does not contain [NF]
    Then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [SBU-NF]. 
    
    Human Readable: USA Unclassified documents having SBU-NF and not having XD, ND, or explicit Foriegn Disclosure and
    Release markings must have SBU-NF at the resource level.</svrl:text>
            <svrl:text> If the document is Unclassifed and is an ISM_USGOV_RESOURCE, the current
    element is the ISM_RESOURCE_ELEMENT, some element meeting ISM_CONTIBUTES specifies attribute
    ism:nonICmarkings with a value containing the token [SBU-NF], and the attribute ism:nonICmarkings
    on the ISM_RESOURCE_ELEMENT does not contain the token [XD] or [ND], and the attribute 
    ism:disseminationControls on the resource element does not contain the token [NF]; 
    this rule ensures sure that ISM_RESOURCE_ELEMENT specifies 
    attribute ism:nonICmarkings with a value containing the token [SBU-NF].</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M217"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00105</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00105</xsl:attribute>
            <svrl:text> [ISM-ID-00105][Error] If the document is an ISM_USGOV_RESOURCE and any
    element in the document is: 
    1. Unclassifed and meets ISM_CONTRIBUTES 
      AND 
    2. Has the attribute nonICmarkings containing [SBU] 
      AND 
    3. No element meeting ISM_CONTRIBUTES in the document has nonICmarkings containing any of [SBU-NF], 
       [XD], or [ND] then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [SBU]. 
    
    Human Readable: USA Unclassified documents having SBU and not
    having SBU-NF, XD, or ND must have SBU at the resource level. </svrl:text>
            <svrl:text> If the document is Unclassfied and is an ISM_USGOV_RESOURCE, the current
    element is the ISM_RESOURCE_ELEMENT, some element meeting ISM_CONTIBUTES specifies attribute
    ism:nonICmarkings with a value containing the token [SBU], and no element meeting
    ISM_CONTRIBUTES specifies attribute ism:nonICmarkings with a value containing the token
    [SBU-NF], [XD], and [ND], then this rule ensures that ISM_RESOURCE_ELEMENT sepcifies attribute
    ism:nonICmarkings with a value containing the token [SBU]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M218"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00107</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00107</xsl:attribute>
            <svrl:text>
        [ISM-ID-00107][Error] If ISM_USGOV_RESOURCE and attribute 
        disseminationControls contains the name token [IMC] then attribute 
        classification must have a value of [TS] or [S].
        
        Human Readable:  IMCON data is SECRET (S), but may appear with 
        S or TOP SECRET data.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM_USGOV_RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [IMC] this rule ensures that attribute ism:classification is not
    	specified with a value of [TS] or [S].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M219"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00108</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00108</xsl:attribute>
            <svrl:text>
    If ISM_USGOV_RESOURCE and attribute classification of ISM_RESOURCE_ELEMENT 
    has a value of [TS] and attribute ism:compilationReason does not have a 
    value, then this rule ensures that at least one element meeting ISM_CONTRIBUTES 
    specifies attribute classification with a value of [TS].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M220"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00109</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00109</xsl:attribute>
            <svrl:text>
    If ISM_USGOV_RESOURCE and attribute classification of ISM_RESOURCE_ELEMENT 
    has a value of [S] and attribute ism:compilationReason does not have a 
    value, then this rule ensures that at least one element meeting ISM_CONTRIBUTES 
    specifies attribute classification with a value of [S].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M221"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00110</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00110</xsl:attribute>
            <svrl:text>
    If ISM_USGOV_RESOURCE and attribute classification of ISM_RESOURCE_ELEMENT 
    has a value of [C] and attribute ism:compilationReason does not have a 
    value, then this rule ensures that at least one element meeting ISM_CONTRIBUTES 
    specifies attribute classification with a value of [C].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M222"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00121</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00121</xsl:attribute>
            <svrl:text>
    For values that contributed to rollup, the values are ordered according to its CVE
    
    To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order.
    
    For values that do not contribute to rollup, the values are ordered alphabetically
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M223"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00124</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00124</xsl:attribute>
            <svrl:text>
      [ISM-ID-00124][Warning] If ISM_USGOV_RESOURCE and
      1. Attribute ownerProducer does not contain [USA].
      AND
      2. Attribute disseminationControls contains [RELIDO]
      
      Human Readable: RELIDO is not authorized for non-US portions.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM_USGOV_RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [RELIDO] this rule ensures that attribute ism:ownerProducer is
    	specified with a value containing [USA].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M224"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00127</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00127</xsl:attribute>
            <svrl:text>Abstract pattern to enforce that an appropriate notice exists for an
		element in $partTags that has a notice requirement. The calling rule must pass $elem,
		'atomicEnergyMarkings', $partTags, and 'RD'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M225"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00128</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00128</xsl:attribute>
            <svrl:text>
		For all elements that contribute to rollup when all of the following are true:
		(a) the given expression $ISM_RESOURCE_ELEMENT/@ism:atomicEnergyMarkings contains the given value 'FRD'
		(b) the given exception expression $ISM_RESOURCE_ELEMENT/@ism:atomicEnergyMarkings does not contain the given exception value 'RD'
		(c) $ISM_USGOV_RESOURCE is true
		
		Assert that some non-resource node element satisfies both
		(a) @ism:noticeType contains the 'FRD' token
		(b) not(@ism:externalNotice is true)

		This rule depends on $partTags defined in the ISM_XML.sch master Schematron file.
		
		The calling rule must pass $ISM_RESOURCE_ELEMENT/@ism:atomicEnergyMarkings, 'FRD', $ISM_RESOURCE_ELEMENT/@ism:atomicEnergyMarkings, 'RD'.
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M226"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00129</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00129</xsl:attribute>
            <svrl:text>Abstract pattern to enforce that an appropriate notice exists for an
		element in $partTags that has a notice requirement. The calling rule must pass $elem,
		'disseminationControls', $partTags, and 'IMC'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M227"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00130</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00130</xsl:attribute>
            <svrl:text>Abstract pattern to enforce that an appropriate notice exists for an
		element in $partTags that has a notice requirement. The calling rule must pass $elem,
		'disseminationControls', $partTags, and 'FISA'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M228"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00132</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00132</xsl:attribute>
            <svrl:text>[ISM-ID-00132][Error] If ISM_USGOV_RESOURCE and the
        ISM_RESOURCE_ELEMENT has the attribute disseminationControls containing [RELIDO] then every
        element meeting ISM_CONTRIBUTES_CLASSIFIED in the document must have the attribute
        disseminationControls containing [RELIDO]. Human Readable: USA documents having RELIDO at
        the resource level must have every classified portion having RELIDO and on any U portions
        that have explicit Release specified must have RELIDO. </svrl:text>
            <svrl:text> 
        If the document is an ISM_USGOV_RESOURCE, the current element is the
        ISM_RESOURCE_ELEMENT, and the ISM_RESOURCE_ELEMENT specifies the attribute
        ism:disseminationControls with a value containing the token [RELIDO] and not an 
        unclass NF-based token (SBU-NF or LES-NF), then this rule ensures that every element 
        meeting ISM_CONTRIBUTES_CLASSIFIED speficies attribute ism:disseminationControls 
        with a value containing the token [RELIDO]. 
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M229"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00133</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00133</xsl:attribute>
            <svrl:text>
		[ISM-ID-00133][Error] If ISM_NSI_EO_APPLIES and attribute 
		declassException is specified and contains the tokens [25X1-EO-12951],
		[50X1-HUM], [50X2-WMD], [NATO], [AEA] or [NATO-AEA] then attribute declassDate or declassEvent must NOT be specified.
		
		Human Readable: Documents under E.O. 13526 must not specify declassDate or declassEvent if 
		a declassException of 25X1-EO-12951, 50X1-HUM, 50X2-WMD, NATO, AEA or NATO-AEA is specified.
	</svrl:text>
            <svrl:text>
		If ISM_NSI_EO_APPLIES, for each element which specifies 
		ism:declassException with a value containing token 
		[25X1-EO-12951], [50X1-HUM], [50X2-WMD], [NATO], [AEA] or [NATO-AEA] this rule ensures that attributes ism:declassDate
		and ism:declassEvent are NOT specified.
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M230"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00134</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00134</xsl:attribute>
            <svrl:text>Abstract pattern to enforce that an appropriate notice exists for an
		element in $partTags that has a notice requirement. The calling rule must pass $elem,
		'nonICmarkings', $partTags, and 'DS'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M231"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00135</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00135</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that for a given element in an
		ISM_USGOV_RESOURCE with @ism:noticeType containing a specified token and ism:externalNotice
		not equal true, 'RD' exists in $partAtomicEnergyMarkings_tok. The calling rule must pass 'RD' and
		@dataTokenList.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M232"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00136</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00136</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that for a given element in an
		ISM_USGOV_RESOURCE with @ism:noticeType containing a specified token and ism:externalNotice
		not equal true, 'FRD' exists in $partAtomicEnergyMarkings_tok. The calling rule must pass 'FRD' and
		@dataTokenList.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M233"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00137</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00137</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that for a given element in an
		ISM_USGOV_RESOURCE with @ism:noticeType containing a specified token and ism:externalNotice
		not equal true, 'IMC' exists in $partDisseminationControls_tok. The calling rule must pass 'IMC' and
		@dataTokenList.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M234"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00138</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00138</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that for a given element in an
		ISM_USGOV_RESOURCE with @ism:noticeType containing a specified token and ism:externalNotice
		not equal true, 'DS' exists in $partNonICmarkings_tok ONLY if the $ISM_RESOURCE_ELEMENT is Unclassified. The calling rule must pass 'DS' and
		@dataTokenList.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M235"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00139</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00139</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that for a given element in an
		ISM_USGOV_RESOURCE with @ism:noticeType containing a specified token and ism:externalNotice
		not equal true, 'FISA' exists in $partDisseminationControls_tok. The calling rule must pass 'FISA' and
		@dataTokenList.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M236"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00141</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00141</xsl:attribute>
            <svrl:text> [ISM-ID-00141][Error] If ISM_NSI_EO_APPLIES and:
        1. ISM_RESOURCE_ELEMENT attribute declassException does not have a value of [25X1-EO-12951], 
        [50X1-HUM], [50X2-WMD], [AEA], [NATO], or [NATO-AEA]
          AND 
        2. ISM_RESOURCE_ELEMENT attribute declassDate is not specified 
          AND 
        3. ISM_RESOURCE_ELEMENT attribute declassEvent is not specified 
        
        Human Readable: Documents under E.O. 13526 require declassDate or declassEvent unless 25X1-EO-12951, 
        50X1-HUM, 50X2-WMD, AEA, NATO, or NATO-AEA is specified. </svrl:text>
            <svrl:text> If ISM_NSI_EO_APPLIES, the current element is the ISM_RESOURCE_ELEMENT,
        and attribtue ism:declassExeption is not specified with a value containing the token
        [25X1-EO-12951], [50X1-HUM], or [50X2-WMD], [AEA], [NATO], or [NATO-AEA] then this rule
        ensures that attribute ism:declassDate is specified or attribute ism:declassEvent is
        specified. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M237"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00142</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00142</xsl:attribute>
            <svrl:text>[ISM-ID-00142][Error] If the Classified National Security Information
        Executive Order applies to the document, then a classification authority must be
        specified.</svrl:text>
            <svrl:text>If ISM_NSI_EO_APPLIES is true (defined in ISM_XML.sch), then the
        resource element (has the attribute @ism:resourceElement="true") must have either
        @ism:classifiedBy or @ism:derivativelyClassifiedBy</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M238"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00143</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00143</xsl:attribute>
            <svrl:text>
        [ISM-ID-00143][Error] If ISM_USGOV_RESOURCE and attribute 
        derivativelyClassifiedBy is specified, then attribute derivedFrom must
        be specified. 
        
        Human Readable: Derivatively Classified data including DOE data requires
        a derived from value to be identified.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM_USGOV_RESOURCE, for each element which 
    	specifies attribute ism:derivativelyClassifiedBy this rule ensures that
    	attribute ism:derivedFrom is specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M239"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00145</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00145</xsl:attribute>
            <svrl:text>
        [ISM-ID-00145][Error] If ISM_USGOV_RESOURCE and any element in the document: 
        1. Meets ISM_CONTRIBUTES
        AND
        2. Has the attribute nonICmarkings containing [LES]
        AND
        3. No element meeting ISM_CONTRIBUTES in the document has nonICmarkings containing any of [LES-NF]
        Then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [LES].
        
        Human Readable: USA documents having LES and not having LES-NF must have LES at the resource level.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_USGOV_RESOURCE, the current element is the 
      ISM_RESOURCE_ELEMENT, some element meeting ISM_CONTIBUTES specifies
      attribute ism:nonICmarkings with a value containing the token [LES], and
      no element meeting ISM_CONTRIBUTES specifies attribute ism:nonICmarkings
      with a value containing the token [LES-NF], then this rule ensures that
      ISM_RESOURCE_ELEMENT sepcifies attribute ism:nonICmarkings with a value
      containing the token [LES].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M240"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00146</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00146</xsl:attribute>
            <svrl:text>
        [ISM-ID-00146][Error] If ISM_USGOV_RESOURCE and there exist at least 2 elements in the document:
        1. Each element: Meets ISM_CONTRIBUTES
        AND
        2. One of the elements: Has the attribute nonICmarkings containing [LES-NF]
        AND
        3. One of the elements: meets ISM_CONTRIBUTES_CLASSIFIED
        Then the ISM_RESOURCE_ELEMENT must have disseminationControls containing [NF].
        
        Human Readable: Classified USA documents having LES-NF Data must have NF at the resource level.
    </svrl:text>
            <svrl:text>
        If IC Markings System Register and Manual rules do not apply to the document then the rule does not apply
        and this rule returns true. If any element has attribute nonICmarkings specified 
        with a value containing [LES-NF] and the resourceElement has attribute classification specified 
        with a value other than [U], then this rule ensures that the resourceElement has attribute 
        disseminationControls specified with a value containing [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M241"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00147</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00147</xsl:attribute>
            <svrl:text>
        [ISM-ID-00147][Error] If ISM_USGOV_RESOURCE and there exist at least 2 elements in the document:
        1. Each element: Meets ISM_CONTRIBUTES
        AND
        2. One of the elements: Has the attribute nonICmarkings containing [LES-NF]
        AND
        3. One of the elements: meets ISM_CONTRIBUTES_CLASSIFIED
        Then the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [LES].
        
        Human Readable: Classified USA documents having LES-NF Data must have LES at the resource level.
    </svrl:text>
            <svrl:text>
        If IC Markings System Register and Manual rules do not apply to the document then the rule does not apply
        and this rule returns true. If any element has attribute nonICmarkings specified 
        with a value containing [LES-NF] and the resourceElement has attribute classification specified 
        with a value other than [U], then this rule ensures that the resourceElement has attribute nonICmarkings
        specified with a value containing [LES].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M242"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00148</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00148</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that mutually exclusive tokens do not exist in
		an attribute. The calling rule must pass @ism:nonICmarkings and ('LES', 'LES-NF').</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M243"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00149</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00149</xsl:attribute>
            <svrl:text>[ISM-ID-00149][Error] If the document is an ISM_USGOV_RESOURCE and:
    1. Any element in the document meets ISM_CONTRIBUTES in the document has the attribute nonICmarkings
       contain [LES-NF] 
      AND 
    2. ISM_RESOURCE_ELEMENT has the attribute classification [U] 
      AND 
    3. ISM_RESOURCE_ELEMENT does not have the attribute dissemination controls [NF] 
       THEN the ISM_RESOURCE_ELEMENT must have nonICmarkings containing [LES-NF]
    
    Human Readable: Unclassified USA documents having LES-NF and not having NF 
    must have LES-NF at the resource level.</svrl:text>
            <svrl:text> If the document is an ISM_USGOV_RESOURCE, the current element is the
    ISM_RESOURCE_ELEMENT, some element meeting ISM_CONTRIBUTES specifies attribute ism:nonICmarkings
    with a value containing the token [LES-NF], and the ISM_RESOURCE_ELEMENT does not have
    attribute ism:disseminationControls with a value containing the token [NF]; then this rule 
    ensures that ISM_RESOURCE_ELEMENT specifies attribute ism:nonICmarkings with a value containing 
    the token [LES-NF].</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M244"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00150</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00150</xsl:attribute>
            <svrl:text>
    [ISM-ID-00150][Error] If ISM_USGOV_RESOURCE and:
    1. Any element, other than ISM_RESOURCE_ELEMENT, meeting ISM_CONTRIBUTES in the document has the attribute nonICmarkings containing [LES]
    AND
    2. No element meeting ISM_CONTRIBUTES in the document has the attribute noticeType containing [LES]
    
    Human Readable: USA documents containing LES data must also have an LES notice.
  </svrl:text>
            <svrl:text>
    If the document is an ISM_USGOV_RESOURCE, for each element which
    is not the ISM_RESOURCE_ELEMENT and meets ISM_CONTRIBUTES and specifies 
    attribute ism:nonICmarkings with a value containing the token [LES], this rule ensures that an element meeting ISM_CONTRIBUTES specifies attribute
    ism:noticeType with a value containing the token [LES].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M245"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00151</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00151</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that for a given element in an
		ISM_USGOV_RESOURCE with @ism:noticeType containing a specified token and ism:externalNotice
		not equal true, 'LES' exists in $partNonICmarkings_tok. The calling rule must pass 'LES' and
		@dataTokenList.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M246"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00152</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00152</xsl:attribute>
            <svrl:text>Abstract pattern to enforce that an appropriate notice exists for an
		element in $partTags that has a notice requirement. The calling rule must pass $elem,
		'nonICmarkings', $partTags, and 'LES-NF'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M247"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00153</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00153</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that for a given element in an
		ISM_USGOV_RESOURCE with @ism:noticeType containing a specified token and ism:externalNotice
		not equal true, 'LES-NF' exists in $partNonICmarkings_tok. The calling rule must pass 'LES-NF' and
		@dataTokenList.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M248"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00154</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00154</xsl:attribute>
            <svrl:text>
    If ISM_USGOV_RESOURCE and attribute disseminationControls of ISM_RESOURCE_ELEMENT 
    has a value of [FOUO] and attribute ism:compilationReason does not have a 
    value, then this rule ensures that at least one element meeting ISM_CONTRIBUTES 
    specifies attribute disseminationControls with a value of [FOUO].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M249"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00159</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00159</xsl:attribute>
            <svrl:text>
        [ISM-ID-00159][Error] If ISM_USGOV_RESOURCE and:
        1. attribute classification of ISM_RESOURCE_ELEMENT is not [U]
        AND
        2. The attribute notice does contain [DoD-Dist-A] 
        or has attribute externalNotice with a value of [true].
        
        Human Readable: Distribution statement A (Public Release) is forbidden on classified documents.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE and the attribute
        classification of ISM_RESOURCE_ELEMENT is not [U], for each element
        which specifies attribute ism:noticeType this rule ensures that attribute
        ism:noticeType is not specified with a value containing the token
        [DoD-Dist-A] unless it is an external notice with attribute ism:externalNotice is [true].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M250"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00164</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00164</xsl:attribute>
            <svrl:text>
        [ISM-ID-00164][Error] If ISM_USGOV_RESOURCE and attribute 
        disseminationControls contains the name token [RS],
        then attribute classification must have a value of [TS] or [S].
        
        Human Readable: USA documents with RISK SENSITIVE dissemination must
        be classified SECRET or TOP SECRET.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM_USGOV_RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [RS] this rule ensures that attribute ism:classification is not
    	specified with a value of [TS] or [S].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M251"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00165</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00165</xsl:attribute>
            <svrl:text> If the document is an ISM_USGOV_RESOURCE and an element meeting
    ISM_CONTRIBUTES specifies attribute ism:disseminationControls with a value containing the token
    [RS], then this rule ensures that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:disseminationControls with a value containing the token [RS]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M252"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00166</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00166</xsl:attribute>
            <svrl:text>Abstract pattern used to warn that an attribute value has a deprecation
		date in its CVE but has not passed based on the ISM_RESOURCE_CREATE_DATE of the resource.
		This pattern uses the deprecation dates in the CVE passed from the calling rule and the
		ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute has a depreciation date,
		which is a warning. The context, CVE name, and Spec name are passed from the calling
		rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M253"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00167</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00167</xsl:attribute>
            <svrl:text>To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M254"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00168</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00168</xsl:attribute>
            <svrl:text>
        [ISM-ID-00168][Error] If ISM_USGOV_RESOURCE and attribute 
        disseminationControls is not specified or is specified and does not contain the name token 
        [DISPLAYONLY], then attribute displayOnlyTo must not be specified.
        
        Human Readable: If a portion in a USA document is not marked for DISPLAY ONLY dissemination, 
        it must not list countries to which it may be disclosed. 
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE and attribute ism:disseminationControls
        does not contain the token [DISPLAYONLY], this rule ensures that the attribute 
      	ism:displayOnlyTo is not specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M255"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00169</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00169</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that mutually exclusive tokens do not exist in
		an attribute. The calling rule must pass @ism:disseminationControls and ('DISPLAYONLY', 'RELIDO', 'NF').</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M256"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00170</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00170</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that an attribute does not contain a
		deprecated token. This pattern uses the deprecation dates in the CVE passed from the calling
		rule and the ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute is
		deprecated, which is an error. The context, CVE name, and Spec name are passed from the
		calling rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M257"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00173</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00173</xsl:attribute>
            <svrl:text> [ISM-ID-00173][Error] If ISM_USGOV_RESOURCE and attribute
        atomicEnergyMarkings contains a name token starting with [RD-SG] or [FRD-SG], then attribute
        classification must have a value of [S] or [TS]. Human Readable: Portions in a USA document
        that contain RD or FRD SIGMA data must be marked SECRET or TOP SECRET. </svrl:text>
            <svrl:text> If the document is an ISM_USGOV_RESOURCE, for each element which has
        attribute ism:atomicEnergyMarkings specified with a value containing a token starting with
        [RD-SG] or [FRD-SG], this rule ensures that the attribute ism:classification has a value of [S]
        or [TS]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M258"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00174</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00174</xsl:attribute>
            <svrl:text>
        [ISM-ID-00174][Error] If ISM_USGOV_RESOURCE and attribute 
        atomicEnergyMarkings contains the name token [RD], [FRD], or [TFNI], 
        then attribute classification must have a value of [TS], [S], or [C].
        
        Human Readable: USA documents with RD, FRD, or TFNI data must be marked CONFIDENTIAL,
        SECRET, or TOP SECRET.
    </svrl:text>
            <svrl:text>
		If the document is an ISM_USGOV_RESOURCE, for each element which has 
		attribute ism:atomicEnergyMarkings specified with a value containing 
		the token [RD], [FRD], or [TFNI], this rule ensures that the attribute 
		ism:classification has a value of [TS], [S], or [C].
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M259"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00175</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00175</xsl:attribute>
            <svrl:text>
        [ISM-ID-00175][Error] If ISM_USGOV_RESOURCE and attribute 
        atomicEnergyMarkings contains the name token [RD-CNWDI], then attribute 
        classification must have a value of [TS] or [S].
    </svrl:text>
            <svrl:text>
		If the document is an ISM_USGOV_RESOURCE, for each element which has 
		attribute ism:atomicEnergyMarkings specified with a value containing 
		the token [RD-CNWDI], this rule ensures that the attribute ism:classification
		has a value of [TS] or [S].
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M260"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00176</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00176</xsl:attribute>
            <svrl:text>

        [ISM-ID-00176][Error] If ISM_USGOV_RESOURCE and attribute 

        atomicEnergyMarkings has a name token containing [RD] or [FRD], 

        then attributes declassDate and declassEvent cannot be specified

        on the resourceElement.

        

        Human Readable: Automatic declassification of documents containing 

        RD or FRD information is prohibited. Attributes declassDate and 

        declassEvent cannot be used in the classification authority block when 

        RD or FRD is present.

    </svrl:text>
            <svrl:text>

    	If the document is an ISM_USGOV_RESOURCE, for each element which 

    	has attribute ism:atomicEnergyMarkings specified with a value containing

the token [RD] or [FRD], this rule ensures that the resourceElement does not

    	have attributes ism:declassDate or ism:declassEvent specified.

    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M261"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00178</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00178</xsl:attribute>
            <svrl:text>To perform sorting, each attribute token
    is converted into a numerical value based on its characters. Next, each attribute token is 
    given an order number, which compares its position to that of its value in the CVE file.
    Next, each order number is compared to that of its previous sibling to determine if the tokens
    are in order. If a token is found whose order number is less than that of its previous sibling, 
    0 is returned for its sorted order number. If a token's order number is greater than that of its 
    previous sibling, 1 is returned. If two tokens have the same order number, their original attribute
    values are compared. If the original attribute value contains numbers then the comparison is made 
    on its converted numerical value; otherwise, the comparison is made on its string value. If an 
    attribute value is found whose value is less than that of its previous sibling,  0 is returned
    for its sorted order number; otherwise 2 is returned. Finally, if any tokens are found with 0 as 
    its sorted order number, then the rule fails as those tokens are out of order. 
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M262"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00179</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00179</xsl:attribute>
            <svrl:text>Abstract pattern used to warn that an attribute value has a deprecation
		date in its CVE but has not passed based on the ISM_RESOURCE_CREATE_DATE of the resource.
		This pattern uses the deprecation dates in the CVE passed from the calling rule and the
		ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute has a depreciation date,
		which is a warning. The context, CVE name, and Spec name are passed from the calling
		rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M263"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00180</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00180</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that an attribute does not contain a
		deprecated token. This pattern uses the deprecation dates in the CVE passed from the calling
		rule and the ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute is
		deprecated, which is an error. The context, CVE name, and Spec name are passed from the
		calling rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M264"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00181</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00181</xsl:attribute>
            <svrl:text>
        [ISM-ID-00181][Error] If ISM_USGOV_RESOURCE and element's 
        classification does not have a value of "U" then attribute atomicEnergyMarkings must not 
        contain the name token [UCNI] or [DCNI].
        
        Human Readable: UCNI and DCNI may only be used on UNCLASSIFIED portions.
    </svrl:text>
            <svrl:text>
		If the document is an ISM_USGOV_RESOURCE, for each element which has 
		attribute ism:atomicEnergyMarkings specified and has attribute 
		ism:classification specified with a value other than [U], this rule ensures that attribute ism:atomicEnergyMarkings does not contain the 
		token [UCNI] or [DNCI].
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M265"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00183</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00183</xsl:attribute>
            <svrl:text>
        [ISM-ID-00183][Error] If ISM_USGOV_RESOURCE and attribute 
        atomicEnergyMarkings contains a name token starting with [RD-SG],
        then it must also contain the name token [RD].
    </svrl:text>
            <svrl:text>
		If the document is an ISM_USGOV_RESOURCE, for each element which has 
		attribute ism:atomicEnergyMarkings specified with a value containing a 
		token starting with [RD-SG], this rule ensures that attribute 
		ism:atomicEnergyMarkings also contains the token [RD].
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M266"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00184</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00184</xsl:attribute>
            <svrl:text>
        [ISM-ID-00184][Error] If ISM_USGOV_RESOURCE and attribute 
        atomicEnergyMarkings contains a name token starting with [FRD-SG],
        then it must also contain the name token [FRD].
    </svrl:text>
            <svrl:text>
		If the document is an ISM_USGOV_RESOURCE, for each element which has 
		attribute ism:atomicEnergyMarkings specified with a value containing a 
		token starting with [FRD-SG], this rule ensures that attribute 
		ism:atomicEnergyMarkings also contains the token [FRD].
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M267"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00185</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00185</xsl:attribute>
            <svrl:text>
        [ISM-ID-00185][Error] If ISM_USGOV_RESOURCE and attribute 
        atomicEnergyMarkings contains the name token [RD-CNWDI],
        then it must also contain the name token [RD].
    </svrl:text>
            <svrl:text>
		If the document is an ISM_USGOV_RESOURCE, for each element which has 
		attribute ism:atomicEnergyMarkings specified with a value containing 
		the token [RD-CNWDI], this rule ensures that attribute 
		ism:atomicEnergyMarkings also contains the token [RD].
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M268"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00186</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00186</xsl:attribute>
            <svrl:text>

        [ISM-ID-00186][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains a token matching [SI-G-XXXX],

        where X is represented by the regular expression character class [A-Z]{4}, then it must also contain the
        name token [SI-G].

        

        Human Readable: A USA document that contains Special Intelligence (SI) GAMMA sub-compartments must

        also specify that it contains SI-GAMMA compartment data.

    </svrl:text>
            <svrl:text>

      If the document is an ISM_USGOV_RESOURCE, for each element which
      specifies attribute ism:SCIcontrols with a value containing a token
      matching [SI-G-XXXX], where X is represented by the regular expression
      character class [A-Z]{4}, this rule ensures that attribute ism:SCIcontrols is 
      specified with a value containing the token [SI-G].

    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M269"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00187</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00187</xsl:attribute>
            <svrl:text>

        [ISM-ID-00187][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [SI-G],

        then it must also contain the name token [SI].

        

        Human Readable: A USA document that contains Special Intelligence (SI) -GAMMA compartment data must also specify that 

        it contains SI data. 

    </svrl:text>
            <svrl:text>

      If the document is an ISM_USGOV_RESOURCE, for each element which
      specifies attribute ism:SCIcontrols with a value containing the token
      [SI-G] this rule ensures that attribute ism:SCIcontrols is 
      specified with a value containing the token [SI].

    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M270"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00188</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00188</xsl:attribute>
            <svrl:text>Abstract pattern used to warn that an attribute value has a deprecation
		date in its CVE but has not passed based on the ISM_RESOURCE_CREATE_DATE of the resource.
		This pattern uses the deprecation dates in the CVE passed from the calling rule and the
		ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute has a depreciation date,
		which is a warning. The context, CVE name, and Spec name are passed from the calling
		rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M271"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00189</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00189</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that an attribute does not contain a
		deprecated token. This pattern uses the deprecation dates in the CVE passed from the calling
		rule and the ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute is
		deprecated, which is an error. The context, CVE name, and Spec name are passed from the
		calling rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M272"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00190</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00190</xsl:attribute>
            <svrl:text>Abstract pattern used to warn that an attribute value has a deprecation
		date in its CVE but has not passed based on the ISM_RESOURCE_CREATE_DATE of the resource.
		This pattern uses the deprecation dates in the CVE passed from the calling rule and the
		ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute has a depreciation date,
		which is a warning. The context, CVE name, and Spec name are passed from the calling
		rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M273"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00191</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00191</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that an attribute does not contain a
		deprecated token. This pattern uses the deprecation dates in the CVE passed from the calling
		rule and the ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute is
		deprecated, which is an error. The context, CVE name, and Spec name are passed from the
		calling rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M274"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00192</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00192</xsl:attribute>
            <svrl:text>Abstract pattern used to warn that an attribute value has a deprecation
		date in its CVE but has not passed based on the ISM_RESOURCE_CREATE_DATE of the resource.
		This pattern uses the deprecation dates in the CVE passed from the calling rule and the
		ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute has a depreciation date,
		which is a warning. The context, CVE name, and Spec name are passed from the calling
		rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M275"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00193</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00193</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that an attribute does not contain a
		deprecated token. This pattern uses the deprecation dates in the CVE passed from the calling
		rule and the ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute is
		deprecated, which is an error. The context, CVE name, and Spec name are passed from the
		calling rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M276"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00196</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00196</xsl:attribute>
            <svrl:text>Abstract pattern used to warn that an attribute value has a deprecation
		date in its CVE but has not passed based on the ISM_RESOURCE_CREATE_DATE of the resource.
		This pattern uses the deprecation dates in the CVE passed from the calling rule and the
		ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute has a depreciation date,
		which is a warning. The context, CVE name, and Spec name are passed from the calling
		rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M277"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00197</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00197</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that an attribute does not contain a
		deprecated token. This pattern uses the deprecation dates in the CVE passed from the calling
		rule and the ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute is
		deprecated, which is an error. The context, CVE name, and Spec name are passed from the
		calling rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M278"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00198</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00198</xsl:attribute>
            <svrl:text>Abstract pattern used to warn that an attribute value has a deprecation
		date in its CVE but has not passed based on the ISM_RESOURCE_CREATE_DATE of the resource.
		This pattern uses the deprecation dates in the CVE passed from the calling rule and the
		ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute has a depreciation date,
		which is a warning. The context, CVE name, and Spec name are passed from the calling
		rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M279"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00199</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00199</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that an attribute does not contain a
		deprecated token. This pattern uses the deprecation dates in the CVE passed from the calling
		rule and the ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute is
		deprecated, which is an error. The context, CVE name, and Spec name are passed from the
		calling rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M280"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00200</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00200</xsl:attribute>
            <svrl:text>Abstract pattern used to warn that an attribute value has a deprecation
		date in its CVE but has not passed based on the ISM_RESOURCE_CREATE_DATE of the resource.
		This pattern uses the deprecation dates in the CVE passed from the calling rule and the
		ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute has a depreciation date,
		which is a warning. The context, CVE name, and Spec name are passed from the calling
		rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M281"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00201</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00201</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that an attribute does not contain a
		deprecated token. This pattern uses the deprecation dates in the CVE passed from the calling
		rule and the ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute is
		deprecated, which is an error. The context, CVE name, and Spec name are passed from the
		calling rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M282"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00202</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00202</xsl:attribute>
            <svrl:text>Abstract pattern used to warn that an attribute value has a deprecation
		date in its CVE but has not passed based on the ISM_RESOURCE_CREATE_DATE of the resource.
		This pattern uses the deprecation dates in the CVE passed from the calling rule and the
		ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute has a depreciation date,
		which is a warning. The context, CVE name, and Spec name are passed from the calling
		rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M283"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00203</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00203</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that an attribute does not contain a
		deprecated token. This pattern uses the deprecation dates in the CVE passed from the calling
		rule and the ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute is
		deprecated, which is an error. The context, CVE name, and Spec name are passed from the
		calling rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M284"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00204</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00204</xsl:attribute>
            <svrl:text>Abstract pattern used to warn that an attribute value has a deprecation
		date in its CVE but has not passed based on the ISM_RESOURCE_CREATE_DATE of the resource.
		This pattern uses the deprecation dates in the CVE passed from the calling rule and the
		ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute has a depreciation date,
		which is a warning. The context, CVE name, and Spec name are passed from the calling
		rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M285"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00205</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00205</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that an attribute does not contain a
		deprecated token. This pattern uses the deprecation dates in the CVE passed from the calling
		rule and the ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute is
		deprecated, which is an error. The context, CVE name, and Spec name are passed from the
		calling rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M286"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00206</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00206</xsl:attribute>
            <svrl:text>Abstract pattern used to warn that an attribute value has a deprecation
		date in its CVE but has not passed based on the ISM_RESOURCE_CREATE_DATE of the resource.
		This pattern uses the deprecation dates in the CVE passed from the calling rule and the
		ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute has a depreciation date,
		which is a warning. The context, CVE name, and Spec name are passed from the calling
		rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M287"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00207</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00207</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that an attribute does not contain a
		deprecated token. This pattern uses the deprecation dates in the CVE passed from the calling
		rule and the ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute is
		deprecated, which is an error. The context, CVE name, and Spec name are passed from the
		calling rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M288"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00208</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00208</xsl:attribute>
            <svrl:text>Abstract pattern used to warn that an attribute value has a deprecation
		date in its CVE but has not passed based on the ISM_RESOURCE_CREATE_DATE of the resource.
		This pattern uses the deprecation dates in the CVE passed from the calling rule and the
		ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute has a depreciation date,
		which is a warning. The context, CVE name, and Spec name are passed from the calling
		rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M289"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00209</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00209</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that an attribute does not contain a
		deprecated token. This pattern uses the deprecation dates in the CVE passed from the calling
		rule and the ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute is
		deprecated, which is an error. The context, CVE name, and Spec name are passed from the
		calling rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M290"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00210</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00210</xsl:attribute>
            <svrl:text>Abstract pattern used to warn that an attribute value has a deprecation
		date in its CVE but has not passed based on the ISM_RESOURCE_CREATE_DATE of the resource.
		This pattern uses the deprecation dates in the CVE passed from the calling rule and the
		ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute has a depreciation date,
		which is a warning. The context, CVE name, and Spec name are passed from the calling
		rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M291"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00211</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00211</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that an attribute does not contain a
		deprecated token. This pattern uses the deprecation dates in the CVE passed from the calling
		rule and the ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute is
		deprecated, which is an error. The context, CVE name, and Spec name are passed from the
		calling rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M292"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00213</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00213</xsl:attribute>
            <svrl:text>
        [ISM-ID-00213][Error] If ISM_USGOV_RESOURCE and attribute 
        disseminationControls contains the name token [DISPLAYONLY], then 
        attribute displayOnlyTo must be specified.
        
        Human Readable: A USA document with DISPLAY ONLY dissemination must 
        indicate the countries to which it may be disclosed.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM_USGOV_RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [DISPLAYONLY] this rule ensures that attribute ism:displayOnlyTo
    	is specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M293"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00214</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00214</xsl:attribute>
            <svrl:text>

        [ISM-ID-00214][Error] If ISM_USGOV_RESOURCE then attribute 

        releasableTo must start with [USA].

    </svrl:text>
            <svrl:text>

        If the document is an ISM_USGOV_RESOURCE, for each element which

        specifies attribute releasableTo this rule ensures that attribute

        releasableTo is specified with a value that starts with the token [USA].

    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M294"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00217</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00217</xsl:attribute>
            <svrl:text>

        [ISM-ID-00217][Error] If ISM_USGOV_RESOURCE attribute FGIsourceProtected
        contains [FGI], it must be the only value.

    </svrl:text>
            <svrl:text>

    	If the document is an ISM_USGOV_RESOURCE, for each element which specifies
    	the attribute ism:FGIsourceProtected, this rule ensures that attribute
    	ism:FGIsourceProtected contains only the token [FGI].

    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M295"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00219</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00219</xsl:attribute>
            <svrl:text>
        [ISM-ID-00219][Error] If element meets ISM_CONTRIBUTES and attribute
        ownerProducer contains the token [FGI], then attribute 
        FGIsourceProtected must have a value containing the token [FGI].
        
        Human Readable: Any non-resource element that contributes to the 
        document's banner roll-up and has FOREIGN GOVERNMENT INFORMATION (FGI)
        must also specify attribute FGIsourceProtected with token FGI.
    </svrl:text>
            <svrl:text>
        For each element which is not the $ISM_RESOURCE_ELEMENT and meets 
        ISM_CONTRIBUTES and specifies attribute ism:ownerProducer with a value
        containing the token [FGI], this rule ensures that attribute 
        ism:FGIsourceProtected is specified with a value containing the
        token [FGI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M296"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00221</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00221</xsl:attribute>
            <svrl:text>
        [ISM-ID-00221][Error] If ISM_USGOV_RESOURCE and attribute 
        derivativelyClassifiedBy is specified, then attributes classificationReason
        or classifiedBy must not be specified.
        
        Human Readable: USA documents that are derivatively classified must not
        specify a classification reason or classified by.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM_USGOV_RESOURCE, for each element which 
    	specifies attribute ism:derivativelyClassifiedBy this rule ensures that
    	attribute ism:classificationReason or ism:classifiedBy is NOT specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M297"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00223</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00223</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list. The calling rule must pass ism:*, local-name(), $validElementList, '   [ISM-ID-00223][Error] If any elements in namespace    urn:us:gov:ic:ism exist, the local name must exist in CVEnumISMElements.xml.       Human Readable: Ensure that elements in the ISM namespace are defined by ISM.XML.   '.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M298"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00226</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00226</xsl:attribute>
            <svrl:text>
        [ISM-ID-00226][Error] Attributes @ism:noticeType and @ism:unregisteredNoticeType
        may not both be used on the same element. 
        
        Human Readable: Ensure that the ISM attributes noticeType and
        unregisteredNoticeType are not used on the same element.
    </svrl:text>
            <svrl:text>
        For each element which has attribute ism:noticeType specified, this rule ensures that ism:unregisteredNoticeType is not specified. 
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M299"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00228</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00228</xsl:attribute>
            <svrl:text>
        [ISM-ID-00228][Error] If ISM_USGOV_RESOURCE and attribute atomicEnergyMarkings of ISM_RESOURCE_ELEMENT contains 
        [FRD] then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        atomicEnergyMarking attribute containing [FRD].
        
        Human Readable: USA documents marked FRD at the resource level must have FRD data.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_USGOV_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:atomicEnergyMarkings is specified
      with a value containing the value [FRD], then this rule ensures that some
      element meeting ISM_CONTRIBUTES specifies attribute ism:atomicEnergyMarkings
      with a value containing [FRD].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M300"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00229</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00229</xsl:attribute>
            <svrl:text>
        [ISM-ID-00229][Error] If ISM_USGOV_RESOURCE and attribute atomicEnergyMarkings of ISM_RESOURCE_ELEMENT contains 
        [RD] then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        atomicEnergyMarking attribute containing [RD].
        
        Human Readable: USA documents marked RD at the resource level must have RD data.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_USGOV_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:atomicEnergyMarkings is specified
      with a value containing the value [RD], then this rule ensures that some
      element meeting ISM_CONTRIBUTES specifies attribute ism:atomicEnergyMarkings
      with a value containing [RD].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M301"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00230</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00230</xsl:attribute>
            <svrl:text>
        [ISM-ID-00230][Error] If ISM_USGOV_RESOURCE and attribute atomicEnergyMarkings of ISM_RESOURCE_ELEMENT contains 
        [FRD-SG-##] then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        atomicEnergyMarking attribute containing the same [FRD-SG-##].
        
        Human Readable: USA documents marked FRD-SG-## at the resource level must have FRD-SG-## data, where ## is the same.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_USGOV_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:atomicEnergyMarkings is specified
      with a value containing a token matching [FRD-SG-##], then this rule ensures that some
      element meeting ISM_CONTRIBUTES specifies attribute ism:atomicEnergyMarkings
      with a value containing a token matching the same [FRD-SG-##].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M302"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00231</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00231</xsl:attribute>
            <svrl:text>
        [ISM-ID-00231][Error] If ISM_USGOV_RESOURCE and attribute atomicEnergyMarkings of ISM_RESOURCE_ELEMENT contains 
        [RD-SG-##] then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        atomicEnergyMarking attribute containing the same [RD-SG-##].
        
        Human Readable: USA documents marked RD-SG-## at the resource level must have RD-SG-## or FRD-SG-## data, where ## is the same.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_USGOV_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:atomicEnergyMarkings is specified
      with a value containing a token matching [RD-SG-##], then this rule ensures that some
      element meeting ISM_CONTRIBUTES specifies attribute ism:atomicEnergyMarkings
      with a value containing a token matching the same [RD-SG-##] or [FRD-SG-##].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M303"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00241</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00241</xsl:attribute>
            <svrl:text>
        [ISM-ID-00241][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [RSV-XXX],
        then it must also contain the name token [RSV].
        
        Human Readable: A USA document that contains RESERVE data (RSV) compartment data must also specify that 
        it contains RSV data. 
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which specifies
        attribute ism:SCIcontrols with a value containing a token matching
        the regular expression "RSV-[A-Z0-9]{3}", this rule ensures that attribute
        ism:SCIcontrols is specified with a value containing the token [RSV].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M304"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00242</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00242</xsl:attribute>
            <svrl:text>
        [ISM-ID-00242][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [RSV],
        then it must also have attribute classification with a value of [S] or [TS].
        
        Human Readable: A USA document that contains RESERVE data must be classified SECRET or TOP SECRET.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_USGOV_RESOURCE, for each element which specifies
      attribute ism:SCIcontrols with a value containing the token [RSV], this rule ensures that attribute ism:classification is specified with a value containing
      the token [TS] or [S].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M305"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00243</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00243</xsl:attribute>
            <svrl:text>
    [ISM-ID-00243][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [RSV],
    then it must also contain a compartment [RSV-XXX].
    
    Human Readable: RESERVE is not permitted as a stand-alone value and a compartment must be expressed.
  </svrl:text>
            <svrl:text>
    If the document is an ISM_USGOV_RESOURCE, for each element which specifies
    attribute ism:SCIcontrols with a value containing the token [RSV], this rule ensures that attribute ism:SCIcontrols is specified with a value containing
    a token maching the regular expression "RSV-[A-Z0-9]{3}".
    
    If IC Markings System Register and Manual rules do not apply to the document then the rule does not apply
    and this rule returns true. If the current element has attribute SCIcontrols specified
    with a value containing [RSV], then this rule ensures that attribute SCIcontrols also contains the value [RSV-XXX].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M306"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00244</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00244</xsl:attribute>
            <svrl:text>
    [ISM-ID-00244][Error] If ISM_USGOV_RESOURCE and:
    1. Any element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings containing [RD-CNWDI]
    AND
    2. No element meeting ISM_CONTRIBUTES in the document has noticeType containing [CNWDI].
    that does not have attribute externalNotice with a value of [true].
    Human Readable: USA documents containing CNWDI data must also have an CNWDI notice.
  </svrl:text>
            <svrl:text>
    If the document is an ISM_USGOV_RESOURCE, for each element meeting
    ISM_CONTRIBUTES which specifies attribute ism:atomicEnergyMarkings with
    a value containing the token [RD-CNWDI], then this rule ensures that some element
    in the document specifies attribute ism:noticeType with a value containing
    the token [CNWDI] and not an attribute externalNotice with a value of [true].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M307"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00245</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00245</xsl:attribute>
            <svrl:text>
        [ISM-ID-00245][Error] If ISM_USGOV_RESOURCE and:
        1. No element without ism:excludeFromRollup=true() in the document has the attribute atomicEnergyMarkings containing [RD-CNWDI]
        AND
        2. Any element without ism:excludeFromRollup=true() in the document has the attribute noticeType containing [CNWDI]
        and not the attribute externalNotice with a value of [true].
        Human Readable: USA documents containing an CNWDI notice must also have RD-CNWDI data.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_USGOV_RESOURCE, for each element which meets
      ISM_CONTRIBUTES and specifies attribute ism:noticeType with a value
      containing the token [CNWDI] and not the attribute externalNotice with a value of [true], then this rule ensures that some element in the
      document specifies attribute ism:atomicEnergyMarkings with a value
      containing the token [RD-CNWDI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M308"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00246</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00246</xsl:attribute>
            <svrl:text>
        [ISM-ID-00246][Error] If ISM_USGOV_RESOURCE and attribute atomicEnergyMarkings of ISM_RESOURCE_ELEMENT contains 
        [RD], [FRD], or [TFNI] then the ISM_RESOURCE_ELEMENT must have a declassException of [AEA] or [NATO-AEA].
        
        Human Readable: USA documents containing [RD], [FRD], or [TFNI] data must have declassException containing [AEA] or [NATO-AEA] at the resource level.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_USGOV_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:atomicEnergyMarkings is specified
      with a value containing a token matching [RD], [FRD], or [TFNI], then this rule ensures that the 
      ISM_RESOURCE_ELEMENT has a declassException of [AEA] or [NATO-AEA].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M309"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00250</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00250</xsl:attribute>
            <svrl:text>
		[ISM-ID-00250][Error] If ISM_USGOV_RESOURCE, element Notice must specify
		attribute ism:noticeType or ism:unregisteredNoticeType.
		
		Human Readable: Notices must specify their type.
	</svrl:text>
            <svrl:text>
		This rule ensures for element ism:Notices must specify their type.
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M310"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00252</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00252</xsl:attribute>
            <svrl:text>
        [ISM-ID-00252][Error] If ISM_RESOURCE_ELEMENT specifies the attribute
        ism:disseminationControls with a value containing the token [RELIDO], 
        then attribute nonICmarkings must not be specified with a value containing 
        the token [NNPI]. 
        
        Human Readable: NNPI tokens are not valid for documents that have
        RELIDO at the resource level.
    </svrl:text>
            <svrl:text>
        For resource elements which have attribute ism:disseminationControls specified 
        with a value containing the token [RELIDO], this rule ensures that attribute 
        ism:nonICmarkings is not specified with a value containing the token [NNPI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M311"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00253</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00253</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M312"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00254</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00254</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M313"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00255</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00255</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M314"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00256</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00256</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M315"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00257</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00257</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M316"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00258</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00258</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M317"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00259</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00259</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M318"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00260</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00260</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M319"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00261</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00261</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if the attribute values of an element 
        exists in a list or matches the pattern defined by the list when these values are flagged as 
        contributing to rollup. The calling rule must pass the context, search term list, attribute value 
        to check, flag on whether the attribute values contribute to rollup, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M320"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00262</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00262</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M321"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00263</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00263</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M322"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00264</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00264</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M323"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00265</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00265</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M324"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00266</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00266</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if the attribute values of an element 
        exists in a list or matches the pattern defined by the list when these values are flagged as 
        contributing to rollup. The calling rule must pass the context, search term list, attribute value 
        to check, flag on whether the attribute values contribute to rollup, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M325"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00267</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00267</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if the attribute values of an element 
        exists in a list or matches the pattern defined by the list when these values are flagged as 
        contributing to rollup. The calling rule must pass the context, search term list, attribute value 
        to check, flag on whether the attribute values contribute to rollup, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M326"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00268</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00268</xsl:attribute>
            <svrl:text>
		[ISM-ID-00268][Error] All atomicEnergyMarkings attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an atomicEnergyMarkings attribute, this rule ensures that the atomicEnergyMarkings value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M327"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00269</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00269</xsl:attribute>
            <svrl:text>
		[ISM-ID-00269][Error] All classification attributes must be of type NmToken. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an classification attribute, this rule ensures that the classification value matches the pattern
		defined for type NmTokens.  
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M328"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00270</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00270</xsl:attribute>
            <svrl:text> [ISM-ID-00270][Error] All classificationReason attributes must be a
		string with 4096 characters or less. </svrl:text>
            <svrl:text> For all elements which contain an classificationReason attribute, this
		rule ensures that the classificationReason value is a string with 4096 characters or less. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M329"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00271</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00271</xsl:attribute>
            <svrl:text>
		[ISM-ID-00271][Error] All classifiedBy attributes must be a string with less than 1024 characters. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an classifiedBy attribute, this rule ensures that the classifiedBy value is a string with less
		than 1024 characters.   
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M330"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00272</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00272</xsl:attribute>
            <svrl:text>
		[ISM-ID-00272][Error] All compilationReason attributes must be a string with less than 1024 characters. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an compilationReason attribute, this rule ensures that the compilationReason value is a string with less
		than 1024 characters.   
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M331"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00273</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00273</xsl:attribute>
            <svrl:text>
		[ISM-ID-00273][Error] All exemptFrom attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an exemptFrom attribute, this rule ensures that the exemptFrom value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M332"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00274</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00274</xsl:attribute>
            <svrl:text>[ISM-ID-00274][Error] All ISM createDate attributes must be a Date
		without a timezone.</svrl:text>
            <svrl:text>For all elements which contain a createDate attribute, this rule ensures that
		the createDate value matches the pattern defined for type Date without timezone information.
		The value must conform to the Regex ‘[0-9]{4}-[0-9]{2}-[0-9]{2}$’</svrl:text>
            <svrl:text>The first assert in this rule is not able to be failed in unit tests. If
		the createDate does not conform to type Date, schematron fails when defining global
		variables before any rules are fired. The first assert is included as a normative statement
		of the requirement that the attribute be a Date type. The rule can fail the second assert,
		which ensures there is no timezone info.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M333"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00275</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00275</xsl:attribute>
            <svrl:text>
		[ISM-ID-00275][Error] All declassDate attributes must be of type Date. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an declassDate attribute, this rule ensures that the declassDate value matches the pattern
		defined for type Date. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M334"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00276</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00276</xsl:attribute>
            <svrl:text>
		[ISM-ID-00276][Error] All declassEvent attributes must be a string with less than 1024 characters. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an declassEvent attribute, this rule ensures that the declassEvent value is a string with less
		than 1024 characters.   
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M335"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00277</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00277</xsl:attribute>
            <svrl:text>
		[ISM-ID-00277][Error] All declassException attributes must be of type NmToken. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an declassException attribute, this rule ensures that the declassException value matches the pattern
		defined for type NmToken. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M336"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00278</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00278</xsl:attribute>
            <svrl:text>
		[ISM-ID-00278][Error] All derivativelyClassifiedBy attributes must be a string with less than 1024 characters. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an derivativelyClassifiedBy attribute, this rule ensures that the derivativelyClassifiedBy value is a string with less
		than 1024 characters.   
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M337"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00279</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00279</xsl:attribute>
            <svrl:text>
		[ISM-ID-00279][Error] All derivedFrom attributes must be a string with less than 1024 characters. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an derivedFrom attribute, this rule ensures that the derivedFrom value is a string with less
		than 1024 characters.   
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M338"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00280</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00280</xsl:attribute>
            <svrl:text>
		[ISM-ID-00280][Error] All displayOnlyTo attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an displayOnlyTo attribute, this rule ensures that the displayOnlyTo value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M339"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00281</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00281</xsl:attribute>
            <svrl:text>
		[ISM-ID-00281][Error] All disseminationControls attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain a disseminationControls attribute, the disseminationControls value must match the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M340"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00282</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00282</xsl:attribute>
            <svrl:text>
		[ISM-ID-00282][Error] All excludeFromRollup attributes must be of type Boolean. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an excludeFromRollup attribute, this rule ensures that the excludeFromRollup value matches the pattern
		defined for type Boolean. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M341"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00283</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00283</xsl:attribute>
            <svrl:text>
		[ISM-ID-00283][Error] All FGIsourceOpen attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an FGIsourceOpen attribute, this rule ensures that the FGIsourceOpen value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M342"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00284</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00284</xsl:attribute>
            <svrl:text>
		[ISM-ID-00284][Error] All FGIsourceProtected attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an FGIsourceProtected attribute, this rule ensures that the FGIsourceProtected value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M343"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00285</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00285</xsl:attribute>
            <svrl:text>
		[ISM-ID-00285][Error] All nonICmarkings attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an nonICmarkings attribute, this rule ensures that the nonICmarkings value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M344"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00286</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00286</xsl:attribute>
            <svrl:text>
		[ISM-ID-00286][Error] All nonUSControls attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an nonUSControls attribute, this rule ensures that the nonUSControls value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M345"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00287</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00287</xsl:attribute>
            <svrl:text>
		[ISM-ID-00287][Error] All noticeDate attributes must be of type Date. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an noticeDate attribute, this rule ensures that the noticeDate value matches the pattern
		defined for type Date. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M346"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00288</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00288</xsl:attribute>
            <svrl:text>
		[ISM-ID-00288][Error] All noticeReason attributes must be a string with less than 2048 characters. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an noticeReason attribute, this rule ensures that the noticeReason value is a string with less
		than 2048 characters.   
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M347"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00289</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00289</xsl:attribute>
            <svrl:text>
		[ISM-ID-00289][Error] All noticeType attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an noticeType attribute, this rule ensures that the noticeType value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M348"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00290</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00290</xsl:attribute>
            <svrl:text>
		[ISM-ID-00290][Error] All externalNotice attributes must be of type Boolean. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an externalNotice attribute, this rule ensures that the externalNotice value matches the pattern
		defined for type Boolean. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M349"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00291</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00291</xsl:attribute>
            <svrl:text>
		[ISM-ID-00291][Error] All ownerProducer attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an ownerProducer attribute, this rule ensures that the ownerProducer value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M350"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00292</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00292</xsl:attribute>
            <svrl:text>
		[ISM-ID-00292][Error] All pocType attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an pocType attribute, this rule ensures that the pocType value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M351"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00293</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00293</xsl:attribute>
            <svrl:text>
		[ISM-ID-00293][Error] All releasableTo attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an releasableTo attribute, this rule ensures that the releasableTo value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M352"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00294</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00294</xsl:attribute>
            <svrl:text>
	  	[ISM-ID-00294][Error] All resourceElement attributes must be of type Boolean. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an resourceElement attribute, this rule ensures that the resourceElement value matches the pattern
		defined for type Boolean. 
		
		Note: this rule is not able to be failed. If the resourceElement does
		not confirm to type Boolean, schematron fails when defining global
		variables before any rules are fired. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M353"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00295</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00295</xsl:attribute>
            <svrl:text>
		[ISM-ID-00295][Error] All SARIdentifier attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an SARIdentifier attribute, this rule ensures that the SARIdentifier value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M354"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00296</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00296</xsl:attribute>
            <svrl:text>
		[ISM-ID-00296][Error] All SCIcontrols attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an SCIcontrols attribute, this rule ensures that the SCIcontrols value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M355"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00297</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00297</xsl:attribute>
            <svrl:text>
		[ISM-ID-00297][Error] All unregisteredNoticeType attributes must be a string with less than 2048 characters. 
	</svrl:text>
            <svrl:text>
		For all elements which contain an unregisteredNoticeType attribute, this rule ensures that the unregisteredNoticeType value is a string with less
		than 2048 characters.   
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M356"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00298</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00298</xsl:attribute>
            <svrl:text>
    If the document is an ISM_USGOV_RESOURCE and an element meeting ISM_CONTRIBUTES
    specifies attribute ism:atomicEnergyMarkings with a value containing the token
    [TFNI] and the exception value(s) are not present, then this rule ensures that 
    the ISM_RESOURCE_ELEMENT specifies the attribute ism:atomicEnergyMarkings with a 
    value containing the token [TFNI].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M357"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00299</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00299</xsl:attribute>
            <svrl:text>
        [ISM-ID-00299][Error] If an element contains the attribute declassException with a value of [AEA], 
        it must also contain the attribute atomicEnergyMarkings.
    </svrl:text>
            <svrl:text>
		If an element contains an ism:declassException attribute with a value containing
		AEA, this rule checks to make sure that element also has an ism:atomicEnergyMarkings
		attribute.
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M358"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00302</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00302</xsl:attribute>
            <svrl:text>
        [ISM-ID-00302][Error] If ISM_USGOV_RESOURCE and attribute 
        disseminationControls contains the name token [OC-USGOV], then 
        name token [OC] must be specified.
        
        Human Readable: A USA document with OC-USGOV dissemination must 
        also contain an OC dissemination.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM_USGOV_RESOURCE, for each element which has 
    	attribute ism:disseminationControls specified with a value containing
    	the token [OC-USGOV], this rule ensures that token [OC] is also specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M359"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00303</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00303</xsl:attribute>
            <svrl:text>
        [ISM-ID-00303][Error] If ISM_USGOV_RESOURCE and the document contains attribute 
        disseminationControls with name token [OC-USGOV] in the banner, then 
        all [OC] portions must also contain [OC-USGOV].
        
        Human Readable: A USA document with OC-USGOV dissemination in the banner
        must also contain OC-USGOV in any OC portions.
    </svrl:text>
            <svrl:text>
    	If the document is an ISM_USGOV_RESOURCE and the resource element
    	contains attribute disseminationControls with name token [OC-USGOV], then this rule ensures that every portion contain name token [OC] also contains 
    	name token [OC-USGOV].    	
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M360"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00304</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00304</xsl:attribute>
            <svrl:text>
        [ISM-ID-00304][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [TK-BLFH],
        then it must also contain the name token [TK].
        
        Human Readable: A USA document that contains TALENT KEYHOLE (TK) -BLUEFISH compartment data must also specify that 
        it contains TK data. 
    </svrl:text>
            <svrl:text>
      If the document is an ISM_USGOV_RESOURCE, for each element which
      specifies attribute ism:SCIcontrols with a value containing the token
      [TK-BLFH] this rule ensures that attribute ism:SCIcontrols is 
      specified with a value containing the token [TK].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M361"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00305</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00305</xsl:attribute>
            <svrl:text>
    [ISM-ID-00305][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [TK-IDIT],
    then it must also contain the name token [TK].
    
    Human Readable: A USA document that contains TALENT KEYHOLE (TK) -IDITAROD compartment data must also specify that 
    it contains TK data. 
  </svrl:text>
            <svrl:text>
    If the document is an ISM_USGOV_RESOURCE, for each element which
    specifies attribute ism:SCIcontrols with a value containing the token
    [TK-IDIT] this rule ensures that attribute ism:SCIcontrols is 
    specified with a value containing the token [TK].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M362"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00306</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00306</xsl:attribute>
            <svrl:text>
    [ISM-ID-00306][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [TK-KAND],
    then it must also contain the name token [TK].
    
    Human Readable: A USA document that contains TALENT KEYHOLE (TK) -KANDIK compartment data must also specify that 
    it contains TK data. 
  </svrl:text>
            <svrl:text>
    If the document is an ISM_USGOV_RESOURCE, for each element which
    specifies attribute ism:SCIcontrols with a value containing the token
    [TK-KAND] this rule ensures that attribute ism:SCIcontrols is 
    specified with a value containing the token [TK].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M363"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00307</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00307</xsl:attribute>
            <svrl:text>
        [ISM-ID-00307][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains a token matching [TK-BLFH-XXXXXX],
        where X is represented by the regular expression character class [A-Z]{1,6}, then it must also contain the
        name token [TK-BLFH].
        
        Human Readable: A USA document that contains TALENT KEYHOLE (TK) BLUEFISH sub-compartments must
        also specify that it contains TK -BLUEFISH compartment data.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing a token
        matching [TK-BLFH-XXXXXX], where X is represented by the regular expression
        character class [A-Z]{1,6}, this rule ensures that attribute ism:SCIcontrols is 
        specified with a value containing the token [TK-BLFH].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M364"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00308</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00308</xsl:attribute>
            <svrl:text>
        [ISM-ID-00308][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains a token matching [TK-IDIT-XXXXXX],
        where X is represented by the regular expression character class [A-Z]{1,6}, then it must also contain the
        name token [TK-IDIT].
        
        Human Readable: A USA document that contains TALENT KEYHOLE (TK) IDITAROD sub-compartments must
        also specify that it contains TK -IDITAROD compartment data.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing a token
        matching [TK-IDIT-XXXXXX], where X is represented by the regular expression
        character class [A-Z]{1,6}, this rule ensures that attribute ism:SCIcontrols is 
        specified with a value containing the token [TK-IDIT].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M365"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00309</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00309</xsl:attribute>
            <svrl:text>
        [ISM-ID-00309][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains a token matching [TK-KAND-XXXXXX],
        where X is represented by the regular expression character class [A-Z]{1,6}, then it must also contain the
        name token [TK-KAND].
        
        Human Readable: A USA document that contains TALENT KEYHOLE (TK) KANDIK sub-compartments must
        also specify that it contains TK -KANDIK compartment data.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing a token
        matching [TK-KAND-XXXXXX], where X is represented by the regular expression
        character class [A-Z]{1,6}, then this rule ensures that attribute ism:SCIcontrols is 
        specified with a value containing the token [TK-KAND].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M366"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00310</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00310</xsl:attribute>
            <svrl:text>
    [ISM-ID-00310][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [SI-EU],
    then it must also contain the name token [SI].
    
    Human Readable: A USA document that contains ENDSEAL (SI) -ECRU compartment data must also specify that 
    it contains =SI data. 
  </svrl:text>
            <svrl:text>
    If the document is an ISM_USGOV_RESOURCE, for each element which
    specifies attribute ism:SCIcontrols with a value containing the token
    [SI-EU] this rule ensures that attribute ism:SCIcontrols is 
    specified with a value containing the token [SI].
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M367"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00311</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00311</xsl:attribute>
            <svrl:text>
        [ISM-ID-00311][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [SI-NK],
        then it must also contain the name token [SI].
        
        Human Readable: A USA document that contains ENDSEAL (SI) -NONBOOK compartment data must also specify that 
        it contains SI data. 
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [SI-NK] this rule ensures that attribute ism:SCIcontrols is 
        specified with a value containing the token [SI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M368"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00313</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00313</xsl:attribute>
            <svrl:text>
        [ISM-ID-00313][Error] If nonICmarkings contains the token [ND] then the 
        attribute disseminationControls must contain [NF].
        
        Human Readable: NODIS data must be marked NOFORN.
    </svrl:text>
            <svrl:text>
        If the nonICmarkings contains the ND token, then check that the disseminationControls
        attribute must have NF specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M369"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00314</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00314</xsl:attribute>
            <svrl:text>
        [ISM-ID-00314][Error] If nonICmarkings contains the token [XD] then the 
        attribute disseminationControls must contain [NF].
        
        Human Readable: EXDIS data must be marked NOFORN.
    </svrl:text>
            <svrl:text>
        If the nonICmarkings contains the ND token, then check that the disseminationControls
        attribute must have NF specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M370"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00315</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00315</xsl:attribute>
            <svrl:text> [ISM-ID-00315][Error] If classified element meets ISM_CONTRIBUTES and
        attribute ownerProducer contains the token [NATO], then attribute declassException must be
        specified with a value of [NATO] or [NATO-AEA] on the resourceElement. 
        
        Human Readable: Any non-resource classified element that contributes to the document's banner 
        roll-up and has NATO Information must also specify a NATO declass exemption on the banner. </svrl:text>
            <svrl:text> In a classified document that meets ISM_USGOV_RESOURCE, for each
        element which is not the $ISM_RESOURCE_ELEMENT and meets ISM_CONTRIBUTES and specifies
        attribute ism:ownerProducer with a value containing the token [NATO], this rule ensures that
        attribute ism:declassExemption on the resource element is specified with a value containing
        the token [NATO] or [NATO-AEA]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M371"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00316</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00316</xsl:attribute>
            <svrl:text>
        [ISM-ID-00316][Error] If ISM_USGOV_RESOURCE and attribute declassExemption of ISM_RESOURCE_ELEMENT contains 
        [NATO] then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        ownerProducer attribute containing [NATO].
        
        Human Readable: USA documents marked with a NATO declass exemption must have NATO portions.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_USGOV_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:declassExemption is specified
      with a value containing the value [NATO], then this rule ensures that some
      element meeting ISM_CONTRIBUTES specifies attribute ism:ownerProducer
      with a value containing [NATO].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M372"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00317</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00317</xsl:attribute>
            <svrl:text>
        [ISM-ID-00317][Error] If ISM_USGOV_RESOURCE and attribute declassExemption of ISM_RESOURCE_ELEMENT contains 
        [NATO-AEA] then at least one element meeting ISM_CONTRIBUTES in the document must have a 
        ownerProducer attribute containing [NATO] and one portion containing ism:atomicEnergyMarkings.
        
        Human Readable: USA documents marked with a NATO-AEA declass exemption must have at least one NATO portion 
        and one portion that contains Atomic Energy Markings.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_USGOV_RESOURCE, the current element is the
      ISM_RESOURCE_ELEMENT, and attribute ism:declassExemption is specified
      with a value containing the value [NATO-AEA], then this rule ensures that some
      element meeting ISM_CONTRIBUTES specifies attribute ism:ownerProducer
      with a value containing [NATO] and ism:atomicEnergyMarkings.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M373"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00318</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00318</xsl:attribute>
            <svrl:text>
    Where an element is the resource element and contains either the @ism:releasableTo or 
    @ism:displayOnlyTo attributes, check that the values specified meet minimum roll-up conditions. 
    Check all contributing portions against the banner for the existence of common countries 
    ensuring that the countries in the banner are the intersection of all contributing portions. 
    Any tetragraphs whose decomposable flag is true will be decomposed into their representative countries.
    
    Once the minimum possibility of intersecting countries is determined, the rule checks that  
    all portions of the banner are included in the subset.  The rule then checks for the case where 
    there are no common countries to be rolled up to the resource element.  Finally, the rule checks to
    ensure that if the banner countries are a subset of the common countries, that a
    compilationReason is specified.  If a compilationReason is not specified, then the banner
    displayOnlyTo countries must be the set of common countries from all contributing portions.
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M374"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00319</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00319</xsl:attribute>
            <svrl:text>[ISM-ID-00319][Error] If ISM_USGOV_RESOURCE and ownerProducer contains 'USA' and attribute
        releasableTo is specified, then releasableTo must contain more than a single token.</svrl:text>
            <svrl:text>If the document is an ISM_USGOV_RESOURCE and a portion's ownerProducer attribute contains 'USA' and specifies
        attribute releasableTo, this rule ensures that the token count for releasableTo is greater than
        1.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M375"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00320</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00320</xsl:attribute>
            <svrl:text>
    Where an element is the resource element and contains either the @ism:releasableTo or 
    @ism:displayOnlyTo attributes, check that the values specified meet minimum roll-up conditions. 
    Check all contributing portions against the banner for the existence of common countries 
    ensuring that the countries in the banner are the intersection of all contributing portions. 
    Any tetragraphs whose decomposable flag is true will be decomposed into their representative countries.
    
    Once the minimum possibility of intersecting countries is determined, the rule checks that  
    all portions of the banner are included in the subset.  The rule then checks for the case where 
    there are no common countries to be rolled up to the resource element.  Finally, the rule checks to
    ensure that if the banner countries are a subset of the common countries, that a
    compilationReason is specified.  If a compilationReason is not specified, then the banner
    displayOnlyTo countries must be the set of common countries from all contributing portions.
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M376"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00321</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00321</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that mutually exclusive tokens do not exist in
		an attribute. The calling rule must pass @ism:atomicEnergyMarkings and ('RD', 'FRD', 'TFNI').</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M377"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00324</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00324</xsl:attribute>
            <svrl:text>
        [ISM-ID-00324][Error] If a document is ISM_USGOV_RESOURCE, it must
        contain portion markings. 
        
        Human Readable: All valid ISM_USGOV_RESOURCE documents must
        also contain portion markings. 
    </svrl:text>
            <svrl:text>
        Make sure that all ISM_USGOV_RESOURCE documents contain at least
        one portion mark if they are not uncaveated UNCLASSIFIED. 
        Allow compilation reason to suffice as an exemption from this rule.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M378"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00325</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00325</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that mutually exclusive tokens do not exist in
		an attribute. The calling rule must pass @ism:disseminationControls and ('OC', 'RELIDO').</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M379"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00326</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00326</xsl:attribute>
            <svrl:text>[ISM-ID-00326][Error] ORCON information (i.e. @ism:disseminationControls of the resource node
      contains [OC]) requires ORCON profile NTK metadata.</svrl:text>
            <svrl:text>If the document is an ISM_USGOV_RESOURCE and the resource node's ism:disseminationControls
      attribute contains [OC], the document must have OC profile NTK metadata. That is, there must be an NTK assertion
      with an ntk:AccessPolicy value of ‘urn:us:gov:ic:aces:ntk:oc’.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M380"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00327</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00327</xsl:attribute>
            <svrl:text>
        [ISM-ID-00327][Error] If ISM_USGOV_RESOURCE and: 
        1. Any element in the document that has the attribute disseminationControls containing [FOUO]
        AND
        2. Has the attribute classification [U]
        
        Then the element can only have the disseminationControls containing [REL], [RELIDO], [NF], [DISPLAYONLY], and [EYES].
        
        Human Readable: Dissemination control markings, excluding Foreign Disclosure and Release markings 
        (REL, RELIDO, NF, DISPLAYONLY, or EYES), in elements of USA Unclassified documents supersede and take precedence 
        over FOUO.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for any element that contains @ism:disseminationControls
        with a value containing [FOUO] and has @ism:classification with a value of [U], 
        then this rule ensures that @ism:disseminationControls only contains the
        tokens [REL], [RELIDO], [NF], [EYES], [DISPLAYONLY], or [FOUO].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M381"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00328</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00328</xsl:attribute>
            <svrl:text>
        [ISM-ID-00328][Error] If ISM_USGOV_RESOURCE and: 
        1. Any element in the document that has the attribute disseminationControls containing [FOUO]
        AND
        2. Has the attribute classification [U]
        
        Then the element can't have any ism:nonICMarkings.
        
        Human Readable: Non-IC dissemination control markings in elements of USA Unclassified documents 
        supersede and take precedence over FOUO.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for any element that contains @ism:disseminationControls
        with a value containing [FOUO] and has @ism:classification with a value of [U], 
        then this rule ensures that there is no @ism:nonICMarkings.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M382"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00329</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00329</xsl:attribute>
            <svrl:text>
        [ISM-ID-00329][Error] Attributes declassEvent and declassDate 
        are mutually exclusive.
    </svrl:text>
            <svrl:text>
		An element cannot have both attributes ism:declassEvent and 
		ism:declassDate.
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M383"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00330</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00330</xsl:attribute>
            <svrl:text>
        [ISM-ID-00330][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [HCS-P], then attribute 
        classification must have a value of [TS], or [S].
        
        Human Readable: A USA document with HCS-PRODUCT compartment data must be classified SECRET or TOP SECRET.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [HCS-P] ensure that attribute ism:classification is 
        specified with a value containing the token [TS], or [S].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M384"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00331</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00331</xsl:attribute>
            <svrl:text>
        [ISM-ID-00331][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains a token matching [HCS-P-XXXXXX],
        where X is represented by the regular expression character class [A-Z0-9]{1,6}, then it must also contain the
        name token [HCS-P].
        
        Human Readable: A USA document with HCS-PRODUCT sub-compartment data must also specify that it contains
        HCS-PRODUCT compartment data.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_USGOV_RESOURCE, for each element which
      specifies attribute ism:SCIcontrols with a value containing a token matching
      [HCS-P-XXXXXX], where X is represented by the regular expression character
      class [A-Z0-9]{1,6}, this rule ensures that attribute ism:SCIcontrols is 
      specified with a value containing the token [HCS-P].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M385"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00332</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00332</xsl:attribute>
            <svrl:text>
        [ISM-ID-00332][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [HCS-O], then attribute 
        classification must have a value of [TS] or [S].
        
        Human Readable: A USA document with HCS-OPERATIONS compartment data must be classified SECRET or TOP SECRET.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [HCS-O], ensure that attribute ism:classification is
        specified with a value of [TS] or [S].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M386"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00333</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00333</xsl:attribute>
            <svrl:text> [ISM-ID-00333][Error] If
    ISM_USGOV_RESOURCE and attribute SCIcontrols contains a token matching [HCS-X], where X is
    represented by the regular expression character class [A-Z], then it must also contain the name
    token [HCS]. 
    
    Human Readable: A USA document with HCS compartment data must also specify that it
    contains HCS data. </svrl:text>
            <svrl:text> If the document is an
    ISM_USGOV_RESOURCE, for each element which specifies attribute ism:SCIcontrols with a value
    containing a token matching [HCS-X], where X is represented by the regular expression character
    class [A-Z], this rule ensures that attribute ism:SCIcontrols is specified with a value
    containing the token [HCS]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M387"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00335</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00335</xsl:attribute>
            <svrl:text>
        [ISM-ID-00335][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [HCS-O],
        then attribute disseminationControls must contain the name token [OC].
        
        Human Readable: A USA document with HCS-OPERATIONS compartment data must be marked for 
        ORIGINATOR CONTROLLED dissemination.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_USGOV_RESOURCE, for each element which
      specifies attribute ism:SCIcontrols with a value containing the token
      [HCS-O], this rule ensures that attribute ism:disseminationControls is
      specified with a value containing the token [OC].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M388"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00336</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00336</xsl:attribute>
            <svrl:text>
        [ISM-ID-00336][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains a token matching [HCS-P-XXXXXX], 
        where X is represented by the regular expression character class [A-Z0-9]{1,6}, then attribute
        disseminationControls must contain the name token [OC].
        
        Human Readable: A USA document with HCS-PRODUCT sub-compartment data must be marked for 
        ORIGINATOR CONTROLLED dissemination.
    </svrl:text>
            <svrl:text>
      If the document is an ISM_USGOV_RESOURCE, for each element which
      specifies attribute ism:SCIcontrols with a value containing a token matching
      [HCS-P-XXXXXX], where X is represented by the regular expression character
      class [A-Z0-9]{1,6}, this rule ensures that attribute ism:disseminationControls is
      specified with a value containing the token [OC].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M389"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00341</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00341</xsl:attribute>
            <svrl:text> [ISM-ID-00341][Error] If ISM_USGOV_RESOURCE and SCIcontrols contains a token matching [SI-G]
        or [SI-G-XXXX], then ism:disseminationControls cannot contain [OC-USGOV] 
        
        Human Readable: OC-USGOV cannot be used if SI-G or an SI-G subs are present. </svrl:text>
            <svrl:text> If the document is an ISM_USGOV_RESOURCE and ism:SCIcontrols contains [SI-G] or [SI-G-XXXX], then
        ism:disseminationControls cannot contain [OC-USGOV] </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M390"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00343</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00343</xsl:attribute>
            <svrl:text>
        [ISM-ID-00343][Error] If ISM_USGOV_RESOURCE and there exists a token in @ism:SCIcontrols for portions that contribute to
        rollup then they must also be specified in the @ism:SCIcontrols attribute on the ISM_RESOURCE_ELEMENT.
        
        Human Readable: All SCI controls specified in the document that contribute to rollup must
        be rolled up to the resource level.
    </svrl:text>
            <svrl:text>
       If the document is an ISM_USGOV_RESOURCE match on the ISM_RESOURCE_ELEMENT if there are any SCIcontrols values specified on portions
       that are not excludeFromRollup="true" and then ensure that all the tokens found exist on the
       element are matched to. If there are any tokens not present in our element that exist elsewhere
       in the document's contributing portions, store them in the missingSCI variable. Then this rule ensures
       that the missingSCI variable is empty or return an error message that specifies which tokens 
       are missing.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M391"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00344</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00344</xsl:attribute>
            <svrl:text>
        [ISM-ID-00344][Error] If ISM_USGOV_RESOURCE and there exists a token in @ism:SCIcontrols on the ISM_RESOURCE_ELEMENT
        and no compilation reason then the token must also be specified in the @ism:SCIcontrols attribute 
        on at least one portion.
        
        Human Readable: All SCI controls specified at the resource level must be found in a contributing
        portion of the document unless there is a compilation reason of the exception.
    </svrl:text>
            <svrl:text>If ISM_USGOV_RESOURCE and attribute @ism:SCIcontrols of
        ISM_RESOURCE_ELEMENT exists and attribute ism:compilationReason does not have a
        value, then this rule ensures that at least one element meeting ISM_CONTRIBUTES specifies attribute
        @ism:SCIcontrols with each value specified on the ISM_RESOURCE_ELEMENT. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M392"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00345</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00345</xsl:attribute>
            <svrl:text>
	  	
	  	[ISM-ID-00345][Error] If ISM_USGOV_RESOURCE and attribute disseminationControls contains the value [EYES], 
	  	releasableTo must only contain the token values of [USA], [AUS], [CAN], [GBR] or [NZL]. 
	  </svrl:text>
            <svrl:text>
	  	If ISM_USGOV_RESOURCE, for each element which specifies the attribute disseminationControls with the value of [EYES], this rule ensures that attribute
	  	releasableTo is specified with the token values of [USA], [AUS], [CAN], [GBR] or [NZL].	  
	  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M393"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00346</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00346</xsl:attribute>
            <svrl:text>
	  	[ISM-ID-00346][Error] If ISM_USGOV_RESOURCE and attribute 
	  	nonICmarkings contains the name token [DS], then attribute
	  	classification must have a value of [U].
	  	
	  	Human Readable: Portions marked DS (LIMDIS) as a nonICmarkings in a USA document
	  	must be classified UNCLASSIFIED.
	</svrl:text>
            <svrl:text>
	  	If the document is an ISM_USGOV_RESOURCE, for each element which has 
	  	attribute ism:nonICmarkings specified with a value containing
	  	the token [DS] this rule ensures that attribute ism:classification is 
	  	specified with a value of [U].
	  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M394"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00347</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00347</xsl:attribute>
            <svrl:text>
        [ISM-ID-00347][Error] If ISM_USGOV_RESOURCE and if there exists a token in @ism:SARIdentifier for portions that contribute to
        rollup then they must also be specified in the @ism:SARIdentifier attribute on the ISM_RESOURCE_ELEMENT.
        
        Human Readable: All SAR Identifiers specified in the document that contribute to rollup must
        be rolled up to the resource level.
    </svrl:text>
            <svrl:text>
       If ISM_USGOV_RESOURCE, match on the ISM_RESOURCE_ELEMENT if there are any SARIdentifier values specified on portions
       that are not excludeFromRollup="true" and then ensure that all the tokens found exist on the
       element are matched to. If there are any tokens not present in our element that exist elsewhere
       in the document's contributing portions, store them in the missingSAR variable. Then check
       that the missingSAR variable is empty or return an error message that specifies which tokens 
       are missing.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M395"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00348</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00348</xsl:attribute>
            <svrl:text>
        [ISM-ID-00348][Error] If ISM_USGOV_RESOURCE and there exists a token in @ism:SARIdentifier on the ISM_RESOURCE_ELEMENT
        and no compilation reason then the token must also be specified in the @ism:SARIdentifer attribute 
        on at least one portion.
        
        Human Readable: All SAR Identifiers specified at the resource level must be found in a contributing
        portion of the document unless there is a compilation reason of the exception.
    </svrl:text>
            <svrl:text>If ISM_USGOV_RESOURCE and attribute @ism:SARIdentifier of
        ISM_RESOURCE_ELEMENT exists and attribute ism:compilationReason does not have a
        value, then this rule ensures that at least one element meeting ISM_CONTRIBUTES specifies attribute
        @ism:SARIdentifier with each value specified on the ISM_RESOURCE_ELEMENT. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M396"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00349</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00349</xsl:attribute>
            <svrl:text>[ISM-ID-00349][Error] If ISM_USGOV_RESOURCE, PROPIN information (i.e. @ism:disseminationControls of the resource
      node contains [PR]) requires PROPIN NTK metadata.</svrl:text>
            <svrl:text>If the document is an ISM_USGOV_RESOURCE and the resource node's @ism:disseminationControls
      attribute contains [PR], the document must have PROPIN profile NTK metadata. That is, there must be an NTK
      assertion with an ntk:AccessPolicy value that starts with ‘urn:us:gov:ic:aces:ntk:propin:’.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M397"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00350</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00350</xsl:attribute>
            <svrl:text>[ISM-ID-00350][Error] Exclusive Distribution information (i.e. @ism:nonICmarkings of the
      resource node contains [XD]) requires XD profile NTK metadata.</svrl:text>
            <svrl:text>If the document is an ISM_USGOV_RESOURCE and the resource nodes's @ism:nonICmarkings
      attribute contains [XD], the document must have XD profile NTK metadata. That is, there must be an NTK assertion
      with an ntk:AccessPolicy value of ‘urn:us:gov:ic:aces:ntk:xd’.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M398"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00351</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00351</xsl:attribute>
            <svrl:text>[ISM-ID-00351][Error] No Distribution information (i.e. @ism:nonICmarkings of the resource
      node contains [ND]) requires ND profile NTK metadata.</svrl:text>
            <svrl:text>If the document is an ISM_USGOV_RESOURCE and the resource node's @ism:nonICmarkings attribute
      contains [ND], the document must have ND profile NTK metadata. That is, there must be an NTK assertion with an
      ntk:AccessPolicy value of ‘urn:us:gov:ic:aces:ntk:nd’.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M399"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00352</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00352</xsl:attribute>
            <svrl:text>Abstract template to validate that for an $ISM_USGOV_RESOURCE, a given token ('PR')
      exists in a particular attribute of at least one of (a) a portion that contributes to roll-up or (b) the banner,
      given the existence of an ntk:AccessProfile that has an ntk:AccessPolicy value that starts with a given string
      ('urn:us:gov:ic:aces:ntk:propin:').</svrl:text>
            <svrl:text>Expected parameters: 'ISM-ID-00352', 'PROPIN', 'urn:us:gov:ic:aces:ntk:propin:', 'disseminationControls', 'PR', $partDisseminationControls_tok, and
      $bannerDisseminationControls_tok</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M400"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00353</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00353</xsl:attribute>
            <svrl:text>Abstract template to validate that for an $ISM_USGOV_RESOURCE, a given token ('OC')
      exists in a particular attribute of at least one of (a) a portion that contributes to roll-up or (b) the banner,
      given the existence of an ntk:AccessProfile that has an ntk:AccessPolicy value that starts with a given string
      ('urn:us:gov:ic:aces:ntk:oc').</svrl:text>
            <svrl:text>Expected parameters: 'ISM-ID-00353', 'ORCON', 'urn:us:gov:ic:aces:ntk:oc', 'disseminationControls', 'OC', $partDisseminationControls_tok, and
      $bannerDisseminationControls_tok</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M401"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00354</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00354</xsl:attribute>
            <svrl:text>Abstract template to validate that for an $ISM_USGOV_RESOURCE, a given token ('XD')
      exists in a particular attribute of at least one of (a) a portion that contributes to roll-up or (b) the banner,
      given the existence of an ntk:AccessProfile that has an ntk:AccessPolicy value that starts with a given string
      ('urn:us:gov:ic:aces:ntk:xd').</svrl:text>
            <svrl:text>Expected parameters: 'ISM-ID-00354', 'EXDIS', 'urn:us:gov:ic:aces:ntk:xd', 'nonICmarkings', 'XD', $partNonICmarkings_tok, and
      $bannerNonICmarkings_tok</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M402"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00355</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00355</xsl:attribute>
            <svrl:text>Abstract template to validate that for an $ISM_USGOV_RESOURCE, a given token ('ND')
      exists in a particular attribute of at least one of (a) a portion that contributes to roll-up or (b) the banner,
      given the existence of an ntk:AccessProfile that has an ntk:AccessPolicy value that starts with a given string
      ('urn:us:gov:ic:aces:ntk:nd').</svrl:text>
            <svrl:text>Expected parameters: 'ISM-ID-00355', 'NODIS', 'urn:us:gov:ic:aces:ntk:nd', 'nonICmarkings', 'ND', $partNonICmarkings_tok, and
      $bannerNonICmarkings_tok</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M403"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00356</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00356</xsl:attribute>
            <svrl:text>Abstract pattern to enforce that an appropriate notice exists for an
		element in $partTags that has a notice requirement. The calling rule must pass $elem,
		'ism:nonICmarkings', $partTags, and 'SSI'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M404"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00357</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00357</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that for a given element in an
		ISM_USGOV_RESOURCE with @ism:noticeType containing a specified token and ism:externalNotice
		not equal true, 'SSI' exists in $partNonICmarkings_tok. The calling rule must pass 'SSI' and
		@dataTokenList.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M405"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00361</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00361</xsl:attribute>
            <svrl:text>
		[ISM-ID-00361][Error] All hasApproximateMarkings attributes must be of type Boolean. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain an hasApproximateMarkings attribute, this rule ensures that the hasApproximateMarkings value matches the pattern
		defined for type Boolean. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M406"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00362</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00362</xsl:attribute>
            <svrl:text>
        [ISM-ID-00362][Error] HCS-P-subs cannot be used with OC-USGOV 
    </svrl:text>
            <svrl:text>
        When OC-USGOV disseminationControls is used, tokens matching the regular expression 
        HCS-P-[A-Z0-9]{1,6} cannot be in SCIcontrols.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M407"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00363</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00363</xsl:attribute>
            <svrl:text>
        [ISM-ID-00363][Error] HCS-O cannot be used with OC-USGOV
    </svrl:text>
            <svrl:text>
        When OC-USGOV disseminationControl is used, HCS-O cannot be in SCIControls.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M408"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00364</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00364</xsl:attribute>
            <svrl:text>
        [ISM-ID-00364][Error] If an ISM_USGOV_RESOURCE has a value in @compilationReason and @noAggregation is present,
        @noAggregation must be false.
    </svrl:text>
            <svrl:text>
        If an ISM_USGOV_RESOURCE has a value in @compilationReason and @noAggregation is present,
        @noAggregation must be false.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M409"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00365</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00365</xsl:attribute>
            <svrl:text>
        [ISM-ID-00365][Error] All noAggregation attributes must be of type Boolean. 
    </svrl:text>
            <svrl:text>
        For all elements which contain an noAggregation attribute, this rule ensures that the noAggregation value matches the pattern
        defined for type Boolean. 
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M410"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00367</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00367</xsl:attribute>
            <svrl:text>
        [ISM-ID-00367][Error] If ISM_USGOV_RESOURCE and attribute derivedFrom is 
        specified, then attribute classifiedBy must not be specified.
        
        Human Readable: USA documents that specify a derivative classifier must not also 
        include information related to Original Classification Authorities (classificationReason and classifiedBy).
    </svrl:text>
            <svrl:text>
    	If the document is an ISM_USGOV_RESOURCE, for each element which 
    	specifies attribute ism:derivativelyClassifiedBy this rule ensures that
    	attribute ism:classificationReason or ism:classifiedBy is NOT specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M411"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00368</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00368</xsl:attribute>
            <svrl:text>
        [ISM-ID-00368][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols
        contains the name token [TK-BLFH], then attribute classification must have
        a value of [TS].
        
        Human Readable: A USA document containing TALENT KEYHOLE (TK) -BLUEFISH compartment data must
        be classified TOP SECRET.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [TK-BLFH] this rule ensures that attribute ism:classification is 
        specified with a value containing the token [TS].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M412"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00369</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00369</xsl:attribute>
            <svrl:text>
        [ISM-ID-00369][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols
        contains the name token [TK-BLFH], then attribute disseminationControls
        must contain the name token [NF].
        
        Human Readable: A USA document containing TALENT KEYHOLE (TK) -BLUEFISH compartment data must also be
        marked for NO FOREIGN dissemination.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [TK-BLFH] this rule ensures that attribute ism:disseminationControls is 
        specified with a value containing the token [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M413"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00370</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00370</xsl:attribute>
            <svrl:text>
        [ISM-ID-00370][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols
        contains the name token [TK-IDIT], then attribute disseminationControls
        must contain the name token [NF].
        
        Human Readable: A USA document containing TALENT KEYHOLE (TK) -IDITAROD compartment data must also be
        marked for NO FOREIGN dissemination.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [TK-IDIT] this rule ensures that attribute ism:disseminationControls is 
        specified with a value containing the token [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M414"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00371</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00371</xsl:attribute>
            <svrl:text>
        [ISM-ID-00371][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols
        contains the name token [TK-KAND], then attribute disseminationControls
        must contain the name token [NF].
        
        Human Readable: A USA document containing TALENT KEYHOLE (TK) -KANDIK compartment data must also be
        marked for NO FOREIGN dissemination.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribute ism:SCIcontrols with a value containing the token
        [TK-KAND] this rule ensures that attribute ism:disseminationControls is 
        specified with a value containing the token [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M415"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00372</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00372</xsl:attribute>
            <svrl:text>
        [ISM-ID-00372][Error] If ISM_USGOV_RESOURCE and attribute nonICmarkings
        contains the name token [LES-NF] or [SBU-NF], then attribute disseminationControls
        must not contain the name token [NF], [REL], [EYES], [RELIDO], or [DISPLAYONLY].
        
        Human Readable: LES-NF and SBU-NF are incompatible with other Foreign Disclosure 
        and Release markings.
    </svrl:text>
            <svrl:text>
        If the document is an ISM_USGOV_RESOURCE, for each element which
        specifies attribute ism:nonICmarkings with a value containing the token
        [LES-NF] or [SBU-NF] this rule ensures that attribute ism:disseminationControls is 
        not specified with a value containing the token [NF], [REL], [EYES], [RELIDO], or 
        [DISPLAYONLY].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M416"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00373</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00373</xsl:attribute>
            <svrl:text> If the document is an ISM_USGOV_RESOURCE and an element meeting
    ISM_CONTRIBUTES specifies attribute ism:nonICmarkings with a value containing the token
    [SSI], then this rule ensures that the ISM_RESOURCE_ELEMENT specifies the attribute
    ism:nonICmarkings with a value containing the token [SSI]. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M417"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00374</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00374</xsl:attribute>
            <svrl:text> 
        [ISM-ID-00374][Error] If ISM_USGOV_RESOURCE and @ism:nonICmarkings contains 'SSI' on the ISM_RESOURCE_ELEMENT
        with no compilation reason then the token 'SSI' must exist in an @ism:nonICmarkings attribute
        on at least one portion. 
         
        Human Readable: If @ism:nonICmarkings contains 'SSI' at the resource level, it must be found in a contributing
        portion of the document unless there is a compilation reason of the exception.
    </svrl:text>
            <svrl:text>If ISM_USGOV_RESOURCE and attribute @ism:nonICmarkings contains 'SSI' 
        on the ISM_RESOURCE_ELEMENT and attribute @ism:compilationReason does not have a
        value, then this rule ensures that at least one element meeting ISM_CONTRIBUTES has attribute
        @ism:nonICmarkings containing 'SSI'.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M418"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00379</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00379</xsl:attribute>
            <svrl:text>[ISM-ID-00379][Error] All ISM declassDate attributes must be a Date
        without a timezone.</svrl:text>
            <svrl:text>For all elements which contain a declassDate attribute, this rule ensures that
        the declassDate value matches the pattern defined for type Date without timezone information.
        The value must conform to the Regex ‘[0-9]{4}-[0-9]{2}-[0-9]{2}$’</svrl:text>
            <svrl:text>The first assert in this rule is not able to be failed in unit tests. If
        the declassDate does not conform to type Date, schematron fails when defining global
        variables before any rules are fired. The first assert is included as a normative statement
        of the requirement that the attribute be a Date type. The rule can fail the second assert,
        which ensures there is no timezone info.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M419"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00380</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00380</xsl:attribute>
            <svrl:text>[ISM-ID-00380][Error] All ISM noticeDate attributes must be a Date
        without a timezone.</svrl:text>
            <svrl:text>For all elements which contain a noticeDate attribute, this rule ensures that
        the noticeDate value matches the pattern defined for type Date without timezone information.
        The value must conform to the Regex ‘[0-9]{4}-[0-9]{2}-[0-9]{2}$’</svrl:text>
            <svrl:text>The first assert in this rule is not able to be failed in unit tests. If
        the noticeDate does not conform to type Date, schematron fails when defining global
        variables before any rules are fired. The first assert is included as a normative statement
        of the requirement that the attribute be a Date type. The rule can fail the second assert,
        which ensures there is no timezone info.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M420"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00119</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00119</xsl:attribute>
            <svrl:text>
        [ISM-ID-00119][Error] If ISM_USIC_RESOURCE and 
        1. attribute classification is not [U]
        AND
        2. not ISM_710_FDR_EXEMPT
        AND
        3. attribute excludeFromRollup is not true
        AND
        4. Attribute disseminationControls must contain one or more of 
            [DISPLAYONLY], [REL], [RELIDO], [EYES], or [NF]

        Human Readable: All classified NSI that does not claim exemption from
        ICD 710 mandatory Foreign Disclosure and Release must have an 
        appropriate foreign disclosure or release marking.
    </svrl:text>
            <svrl:text>
        If IC Markings System Register and Manual rules do not apply to the document, or the document is exempt from mandatory
        foreign disclosure and release markings, or the resource is unclassified, or 
        excludeFromRollup is true, then the rule does not apply. 
        Otherwise, this rule ensures that the attribute disseminationControls contains at least
        one of the values [DISPLAYONLY], [RELIDO], [REL], [EYES], or [NF].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M421"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00225</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00225</xsl:attribute>
            <svrl:text>
        [ISM-ID-00225][Error] If subject to IC rules, then attribute 
        nonICmarkings must not be specified with a value containing any name 
        token starting with [ACCM] or [NNPI]. 
        
        Human Readable: ACCM and NNPI tokens are not valid for documents that are subject
        to IC rules.
    </svrl:text>
            <svrl:text>
        If ISM_USIC_RESOURCE, for each element which has attribute 
    	ism:nonICmarkings specified, this rule ensures that attribute
    	ism:nonICmarkings is not specified with a value containing a token
    	which starts with [ACCM] or [NNPI].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M422"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00251</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00251</xsl:attribute>
            <svrl:text>
        [ISM-ID-00251][Error] If US IC resource, then attribute 
        @ism:noticeType must not be specified with a value of [COMSEC]. 
        
        Human Readable: COMSEC notices are not valid for US IC documents.
    </svrl:text>
            <svrl:text>
    	If ISM_USIC_RESOURCE, for each element which has attribute 
    	@ism:noticeType specified, this rule ensures that attribute
    	@ism:noticeType is not specified with a value containing token
    	[COMSEC].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M423"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00002</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00002</xsl:attribute>
            <svrl:text>
        [ISM-ID-00002][Error] For every attribute in the ISM namespace that is
        used in a document a non-null value must be present.
    </svrl:text>
            <svrl:text>
        For each element which defines an attribute in the ISM namespace, This rule ensures that each attribute in the ISM namespace is specified with 
        a non-whitespace value.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M424"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00012</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00012</xsl:attribute>
            <svrl:text>
        [ISM-ID-00012][Error] If any of the attributes defined in 
        this DES other than DESVersion, ISMCATCESVersion, unregisteredNoticeType, or pocType 
        are specified for an element, then attributes classification and 
        ownerProducer must be specified for the element.
    </svrl:text>
            <svrl:text>
    	For each element which defines an attribute in the ISM namespace other
    	than ism:pocType, ism:DESVersion, ism:ISMCATCESVersion, or ism:unregisteredNoticeType, this rule ensures that attributes ism:classification and ism:ownerProducer are
    	specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M425"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00102</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00102</xsl:attribute>
            <svrl:text>
        [ISM-ID-00102][Error] The attribute 
        DESVersion in the namespace urn:us:gov:ic:ism must be specified.
        
        Human Readable: The data encoding specification version must
        be specified.
    </svrl:text>
            <svrl:text>
        Make sure that the attribute ism:DESVersion 
        is specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M426"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00103</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00103</xsl:attribute>
            <svrl:text>
        [ISM-ID-00103][Error] At least one element must have attribute 
        resourceElement specified with a value of [true].
    </svrl:text>
            <svrl:text>
        For the document, this rule ensures that at least one element specifies 
        attribute ism:resourceElement with a value of [true].
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M427"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00118</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00118</xsl:attribute>
            <svrl:text>
        [ISM-ID-00118][Error] The first element in document order having 
        resourceElement true must have createDate specified.
    </svrl:text>
            <svrl:text>
        This rule ensures that the resourceElement has attribute createDate specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M428"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00125</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00125</xsl:attribute>
            <svrl:text>
    [ISM-ID-00125][Error] If any attributes in namespace 
    urn:us:gov:ic:ism exist, the local name must exist in CVEnumISMAttributes.xml. 
    
    Human Readable: Ensure that attributes in the ISM namespace are defined by ISM.XML.
  </svrl:text>
            <svrl:text>
    This rule uses an abstract pattern to consolidate logic. It checks that the
    value in parameter $searchTerm is contained in the parameter $list. The parameter
    $searchTerm is relative in scope to the parameter $context. The value for the parameter 
    $list is a variable defined in the main document (ISM_XML.sch), which reads 
    values from a specific CVE file.
  </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M429"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00163</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00163</xsl:attribute>
            <svrl:text>
        [ISM-ID-00163][Error] If attribute nonUSControls exists either 
        1. the attribute ownerProducer must equal [NATO] or a [NATO:NAC] 
            OR 
        2. the attribute FGIsourceOpen must contain [NATO] or a [NATO:NAC]
            OR
        3. the attribute FGIsourceProtected is used (This should only be the case when it is a resource level or super portion marking)
        
        Human Readable: NATO and NATO/NACs are the only owner of classification markings
        for which nonUSControls are currently authorized.
    </svrl:text>
            <svrl:text>
        For each element which specifies attribute ism:nonUSControls, this rule ensures that either the attributes ism:ownerProducer or ism:FGIsourceOpen are specified with a value of [NATO] or [NATO:NAC]
        OR the ism:FGIsourceProtected attribute is specified. </svrl:text>
            <svrl:text>        
        NOTE: The last case with FGIsourceProtected should only occur when the element is either a resource node or 
        is a super-portion such as the marking of a table where the table contains one or more portions meeting 1 or 2 from the rule description 
        AND one or more portions with the FGIsourceProtected specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M430"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00194</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00194</xsl:attribute>
            <svrl:text>Abstract pattern used to warn that an attribute value has a deprecation
		date in its CVE but has not passed based on the ISM_RESOURCE_CREATE_DATE of the resource.
		This pattern uses the deprecation dates in the CVE passed from the calling rule and the
		ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute has a depreciation date,
		which is a warning. The context, CVE name, and Spec name are passed from the calling
		rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M431"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00195</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00195</xsl:attribute>
            <svrl:text>Abstract pattern to ensure that an attribute does not contain a
		deprecated token. This pattern uses the deprecation dates in the CVE passed from the calling
		rule and the ISM_RESOURCE_CREATE_DATE to determine if a token in the attribute is
		deprecated, which is an error. The context, CVE name, and Spec name are passed from the
		calling rule.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M432"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00236</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00236</xsl:attribute>
            <svrl:text> [ISM-ID-00236][Error] Duplicate tokens are not permitted in ISM
        attributes.</svrl:text>
            <svrl:text> To determine the valid values, this rule first retrieves the CVE values
        for the attribute, which in this case is classification. Then, each attribute token is
        converted into a numerical value based on its characters. Next, each attribute token is
        given an order number, which compares its position to that of its value in the CVE file. If
        the token is not found, its order number will be -1. If the document is an IC resource and
        the ownerProducer of this element is 'USA', then the rule will fail if tokens are found with
        order numbers of -1. The rule will also fail if duplicate values are found for the element,
        or when its count is greater than 1. </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M433"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00248</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00248</xsl:attribute>
            <svrl:text>
		[ISM-ID-00248][Error] ISM_RESOURCE_ELEMENT cannot have externalNotice set to [true].
		
		Human Readable: ISM resource elements can not be external notices.
	</svrl:text>
            <svrl:text>
	  	If ISM_RESOURCE_ELEMENT, this rule ensures that the ISM_RESOURCE_ELEMENT does not contain
		externalNotice set to [true].
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M434"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00300</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00300</xsl:attribute>
            <svrl:text>
        [ISM-ID-00300][Warning] DESVersion attributes SHOULD be specified as revision 201609.201707 with an optional extension.
    </svrl:text>
            <svrl:text>
        This rule supports extending the version identifier with an optional trailing hypen
        and up to 23 additional characters. The version must match the regular expression
        “^201609.201707(-.{1,23})?$
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M435"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00322</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00322</xsl:attribute>
            <svrl:text>
        [ISM-ID-00322][Warning] The @ism:ISMCATCESVersion imported by ISM SHOULD be greater than or equal to 201707.
        
        Human Readable: The ISMCAT version imported by ISM SHOULD be greater than or equal to 2017-JUL. 
    </svrl:text>
            <svrl:text>
        For all elements that contain @ism:ISMCATCESVersion, this rule checks that the version
        is greater than or equal to the minimum allowed version: 201707. 
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M436"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00323</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00323</xsl:attribute>
            <svrl:text>
        [ISM-ID-00323][Error] The attribute 
        ISMCATCESVersion in the namespace urn:us:gov:ic:ism must be specified.
        
        Human Readable: The CVE encoding specification version for ISM CAT must
        be specified.
    </svrl:text>
            <svrl:text>
        This rule ensures that the attribute ism:ISMCATCESVersion 
        is specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M437"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00337</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00337</xsl:attribute>
            <svrl:text>
        [ISM-ID-00337][Error] The first element in document order having 
        resourceElement true must have compliesWith specified.
    </svrl:text>
            <svrl:text>
        This rule ensures that the resourceElement has attribute compliesWith specified.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M438"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00338</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00338</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M439"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00339</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00339</xsl:attribute>
            <svrl:text>
        
        [ISM-ID-00339][Error] 
        1. ism:ownerProducer of resource element contains USA
        2. ism:compliesWith does not contain USGov
        
        Human Readable: All documents that contain USA in @ism:ownerProducer of
        the first resource node (in document order) must claim USGov in @ism:compliesWith
    </svrl:text>
            <svrl:text>
        If a document contains USA in @ism:ownerProducer (for the resource element), then
        @ism:compliesWith must contain USGov.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M440"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00340</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00340</xsl:attribute>
            <svrl:text>
		[ISM-ID-00340][Error] All compliesWith attributes must be of type NmTokens. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain a compliesWith attribute, this rule ensures that the compliesWith value matches the pattern
		defined for type NmTokens. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M441"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00358</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00358</xsl:attribute>
            <svrl:text>
	  	[ISM-ID-00358][Error] A document using tetragraphs may not have a releasableTo or 
	  	that is less restrictive than that of any tetragraph or organization 
	  	tokens used in the releasableTo fields.
	</svrl:text>
            <svrl:text>
	  	Determine the set of releasable countries by determining, for each token, if it is a country code or tetragraph.
	  	If it is a tetragraph get the membership from CATT, otherwise add the token to the list. Then determine if any
	  	of the tetragraph tokens have releasability restrictions themselves. If so, add that token to a list. Finally,
	  	determine if the releasability of the tetragraph tokens are more restrictive then the releasability of the document.
	  	If there are, trigger the error message.
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M442"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00359</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00359</xsl:attribute>
            <svrl:text>
        [ISM-ID-00359][Error] The classification of a tetragraph may not be greater 
        than the classification of the document.
    </svrl:text>
            <svrl:text>
        For documents that use tetragraphs, this rule verifies that the classification of the tetragraph isn't greater
        than the classification of the document.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M443"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00360</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00360</xsl:attribute>
            <svrl:text>
        [ISM-ID-00360][Error] An UNCLASSIFIED//FOUO tetragraph may not be used in a UNCLASSIFIED document that is not
            also FOUO.
    </svrl:text>
            <svrl:text>
        For documents that use tetragraphs, this rule verifies that if a tetragraph is UNCLASSIFIED//FOUO, and the document is UNCLASSIFIED,
        then the document must also be FOUO.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M444"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00366</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00366</xsl:attribute>
            <svrl:text>
        [ISM-ID-00366][Error] The @ntk:DESVersion is less than the minimum version 
        allowed: 201508. 
        
        Human Readable: The NTK version imported by ISM must be greater than or equal to 2015-AUG. 
    </svrl:text>
            <svrl:text>
        For all elements that contain @ntk:DESVersion, this rule verifies that the version
        is greater than or equal to the minimum allowed version: 201508.  
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M445"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00375</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00375</xsl:attribute>
            <svrl:text>
        [ISM-ID-00375][Error] The ISMCATCESVersion being used for validation does not contain the needed
        TetragraphTaxonomy files. This will prevent ISM validation from functioning. NOTE: This is not an
        erorr of the instance document but of the validation environment itself.
        
        Human Readable: The version of ISMCAT being used in the validaiton infrastructure is missing essential
        components required for ISM validation to proceed. Regardless of the version indicated on the instance 
        document, the validation infrastructure needs to use a minimum version of ISMCAT that is 2017-JUL or later.
    </svrl:text>
            <svrl:text>
        Verifies that the validation infrastructure has the minimum required version of ISMCAT by checking the
        version declared in the ISMCAT Tetragraph CVE.
    </svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M446"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00376</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00376</xsl:attribute>
            <svrl:text>
	  	[ISM-ID-00376][Error]A portion using tetragraphs may not have a releasableTo 
	  	that is less restrictive than the releasability of any tetragraph or organization tokens used
	  	in the same portion’s releasableTo, displayOnlyto, FGISourceOpen, or FGISourceProtected fields.
	</svrl:text>
            <svrl:text>
	  	Determine the set of releasable countries by determining, for each token, if it is a country code or tetragraph.
	  	If it is a tetragraph get the membership from CATT, otherwise add the token to the list. Then determine if any
	  	of the tetragraph tokens have releasability restrictions themselves. If so, add that token to a list. Finally,
	  	determine if the releasability of the tetragraph tokens are more restrictive then the releasability of the portion.
	  	If there are, trigger the error message.
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M447"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00377</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00377</xsl:attribute>
            <svrl:text>This abstract pattern checks to see if an attribute of an element exists
        in a list or matches the pattern defined by the list. The calling rule must pass the
        context, search term list, attribute value to check, and an error message.</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M448"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00378</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00378</xsl:attribute>
            <svrl:text>
		[ISM-ID-00378][Error] All joint attributes must be of type Boolean. 
	</svrl:text>
            <svrl:text>
	  	For all elements which contain a joint attribute, this rule ensures that the joint value matches the pattern
		defined for type Boolean. 
	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M449"/>
         <svrl:active-pattern>
            <xsl:attribute name="document">
               <xsl:value-of select="document-uri(/)"/>
            </xsl:attribute>
            <xsl:attribute name="id">ISM-ID-00381</xsl:attribute>
            <xsl:attribute name="name">ISM-ID-00381</xsl:attribute>
            <svrl:text>
	  	[ISM-ID-00381][Error] 
	  	1. ism:compliesWith of resource element contains USIC or USDOD
	  	2. ism:compliesWith must also contain USGov

	</svrl:text>
            <xsl:apply-templates/>
         </svrl:active-pattern>
         <xsl:apply-templates select="/" mode="M450"/>
      </svrl:schematron-output>
   </xsl:template>

   <!--SCHEMATRON PATTERNS-->


<!--PATTERN typeConstraintPatterns-->
<xsl:variable name="NameStartCharPattern" select="':|[A-Z]|_|[a-z]'"/>
   <xsl:variable name="NameCharPattern"
                 select="concat($NameStartCharPattern, '|-|\.|[0-9]')"/>
   <xsl:variable name="NmTokenPattern" select="concat('(', $NameCharPattern, ')+')"/>
   <xsl:variable name="NmTokensPattern"
                 select="concat($NmTokenPattern, '( ', $NmTokenPattern, ')*')"/>
   <xsl:variable name="BooleanPattern" select="'(false|true|0|1)'"/>
   <xsl:variable name="DatePattern"
                 select="'-?([1-9][0-9]{3,}|0[0-9]{3})-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])(Z|(\+|-)((0[0-9]|1[0-3]):[0-5][0-9]|14:00))?'"/>
   <xsl:template match="text()" priority="-1" mode="M7"/>
   <xsl:template match="@*|node()" priority="-2" mode="M7">
      <xsl:apply-templates select="*" mode="M7"/>
   </xsl:template>
   <xsl:param name="countriesList"
              select="document('../../CVE/ISMCAT/CVEnumISMCATOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="classificationAllList"
              select="document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="classificationUSList"
              select="document('../../CVE/ISM/CVEnumISMClassificationUS.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="ownerProducerList"
              select="document('../../CVE/ISMCAT/CVEnumISMCATOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="declassExceptionList"
              select="document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="FGIsourceOpenList"
              select="document('../../CVE/ISMCAT/CVEnumISMCATFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="FGIsourceProtectedList"
              select="document('../../CVE/ISMCAT/CVEnumISMCATFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="nonICmarkingsList"
              select="document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="releasableToList"
              select="document('../../CVE/ISMCAT/CVEnumISMCATRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="SCIcontrolsList"
              select="document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="SARIdentifierList"
              select="document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="validAttributeList"
              select="document('../../CVE/ISM/CVEnumISMAttributes.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="validElementList"
              select="document('../../CVE/ISM/CVEnumISMElements.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="noticeList"
              select="document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="nonUSControlsList"
              select="document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="exemptFromList"
              select="document('../../CVE/ISM/CVEnumISMExemptFrom.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="atomicEnergyMarkingsList"
              select="document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="displayOnlyToList"
              select="document('../../CVE/ISMCAT/CVEnumISMCATRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="pocTypeList"
              select="document('../../CVE/ISM/CVEnumISMPocType.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="compliesWithList"
              select="document('../../CVE/ISM/CVEnumISMCompliesWith.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="catRaw"
              select="document('../../Taxonomy/ISMCAT/TetragraphTaxonomy.xml')"/>
   <xsl:param name="catt"
              select="document('../../Taxonomy/ISMCAT/TetragraphTaxonomyDenormalized.xml')"/>
   <xsl:param name="cattMappings" select="$catt//catt:Tetragraph"/>
   <xsl:param name="tetragraphList"
              select="document('../../CVE/ISMCAT/CVEnumISMCATTetragraph.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="countriesAndTetras"
              select="distinct-values(for $each in distinct-values((/descendant-or-self::node()//@ism:ownerProducer | /descendant-or-self::node()//@ism:releasableTo | /descendant-or-self::node()//@ism:displayOnlyTo | /descendant-or-self::node()//@ism:FGIsourceOpen | /descendant-or-self::node()//@ism:FGIsourceProtected)) return util:tokenize($each))"/>
   <xsl:param name="tetras"
              select="for $value in $countriesAndTetras return if ($catt//catt:Tetragraph[catt:TetraToken=$value]) then $value else null"/>
   <xsl:param name="catt_new"
              select="for $node in $catt//* return if (local-name($node)='Organization') then 'MEM' else $node"/>
   <xsl:param name="disseminationControlsList"
              select="document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term/cve:Value"/>
   <xsl:param name="ISM_RESOURCE_ELEMENT"
              select="          (for $each in (//*)          return             if (                                                                               if(string( $each/@ism:resourceElement) castable as xs:boolean)                                                                                    then                                                                                       if($each/@ism:resourceElement = true()) then true() else false()                                                                                    else false())                                                                             then   $each else null)[1]"/>
   <xsl:param name="ISM_RESOURCE_CREATE_DATE"
              select="$ISM_RESOURCE_ELEMENT/@ism:createDate"/>
   <xsl:param name="ISM_USGOV_RESOURCE"
              select="util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:compliesWith, ('USGov'))"/>
   <xsl:param name="ISM_OTHER_AUTH_RESOURCE"
              select="util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:compliesWith, ('OtherAuthority'))"/>
   <xsl:param name="ISM_USIC_RESOURCE"
              select="util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:compliesWith, ('USIC'))"/>
   <xsl:param name="ISM_USDOD_RESOURCE"
              select="util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:compliesWith, ('USDOD'))"/>
   <xsl:param name="ISM_710_FDR_EXEMPT"
              select="index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:exemptFrom)), ' '), 'IC_710_MANDATORY_FDR') &gt; 0 or not($ISM_USIC_RESOURCE)"/>
   <xsl:param name="ISM_DOD_DISTRO_EXEMPT"
              select="index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:exemptFrom)), ' '), 'DOD_DISTRO_STATEMENT') &gt; 0 or not($ISM_USDOD_RESOURCE)"/>
   <xsl:param name="ISM_ORCON_POC_DATE" select="xs:date('2011-03-11')"/>
   <xsl:param name="bannerClassification"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:classification))"/>
   <xsl:param name="bannerDisseminationControls"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:disseminationControls))"/>
   <xsl:param name="bannerDisplayOnlyTo"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:displayOnlyTo))"/>
   <xsl:param name="bannerNonICmarkings"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:nonICmarkings))"/>
   <xsl:param name="bannerFGIsourceOpen"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:FGIsourceOpen))"/>
   <xsl:param name="bannerFGIsourceProtected"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:FGIsourceProtected))"/>
   <xsl:param name="bannerReleasableTo"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:releasableTo))"/>
   <xsl:param name="bannerSCIcontrols"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:SCIcontrols))"/>
   <xsl:param name="bannerNotice"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:noticeType))"/>
   <xsl:param name="bannerSARIdentifier"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:SARIdentifier))"/>
   <xsl:param name="bannerAtomicEnergyMarkings"
              select="normalize-space(string($ISM_RESOURCE_ELEMENT/@ism:atomicEnergyMarkings))"/>
   <xsl:param name="bannerDisseminationControls_tok"
              select="tokenize(normalize-space(string($bannerDisseminationControls)), ' ')"/>
   <xsl:param name="bannerDisplayOnlyTo_tok"
              select="tokenize(normalize-space(string($bannerDisplayOnlyTo)), ' ')"/>
   <xsl:param name="bannerNonICmarkings_tok"
              select="tokenize(normalize-space(string($bannerNonICmarkings)), ' ')"/>
   <xsl:param name="bannerFGIsourceOpen_tok"
              select="tokenize(normalize-space(string($bannerFGIsourceOpen)), ' ')"/>
   <xsl:param name="bannerFGIsourceProtected_tok"
              select="tokenize(normalize-space(string($bannerFGIsourceProtected)), ' ')"/>
   <xsl:param name="bannerReleasableTo_tok"
              select="tokenize(normalize-space(string($bannerReleasableTo)), ' ')"/>
   <xsl:param name="bannerSCIcontrols_tok"
              select="tokenize(normalize-space(string($bannerSCIcontrols)), ' ')"/>
   <xsl:param name="bannerNotice_tok"
              select="tokenize(normalize-space(string($bannerNotice)), ' ')"/>
   <xsl:param name="bannerSARIdentifier_tok"
              select="tokenize(normalize-space(string($bannerSARIdentifier)), ' ')"/>
   <xsl:param name="bannerAtomicEnergyMarkings_tok"
              select="tokenize(normalize-space(string($bannerAtomicEnergyMarkings)), ' ')"/>
   <xsl:param name="partTags"
              select="/descendant-or-self::node()[@ism:classification and util:contributesToRollup(.) and not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))]"/>
   <xsl:param name="partClassification"
              select="          for $token in $partTags/@ism:classification          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partOwnerProducer"
              select="          for $token in $partTags/@ism:ownerProducer          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partDisseminationControls"
              select="          for $token in $partTags/@ism:disseminationControls          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partDisplayOnlyTo"
              select="          for $token in $partTags/@ism:displayOnlyTo          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partAtomicEnergyMarkings"
              select="          for $token in $partTags/@ism:atomicEnergyMarkings          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partNonICmarkings"
              select="          for $token in $partTags/@ism:nonICmarkings          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partFGIsourceOpen"
              select="          for $token in $partTags/@ism:FGIsourceOpen          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partFGIsourceProtected"
              select="          for $token in $partTags/@ism:FGIsourceProtected          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partSCIcontrols"
              select="          for $token in $partTags/@ism:SCIcontrols          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partNoticeType"
              select="          for $token in $partTags/@ism:noticeType          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partSARIdentifier"
              select="          for $token in $partTags/@ism:SARIdentifier          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partPocType"
              select="//*/@ism:pocType[util:contributesToRollup(./parent::node()) and not(generate-id(./parent::node()) = generate-id($ISM_RESOURCE_ELEMENT)) and not(./parent::node()/@ism:externalNotice = true())]"/>
   <xsl:param name="partClassification_tok"
              select="          for $token in $partClassification          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partOwnerProducer_tok"
              select="          for $token in $partOwnerProducer          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partDisseminationControls_tok"
              select="          for $token in $partDisseminationControls          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partDisplayOnlyTo_tok"
              select="          for $token in $partDisplayOnlyTo          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partAtomicEnergyMarkings_tok"
              select="          for $token in $partAtomicEnergyMarkings          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partNonICmarkings_tok"
              select="          for $token in $partNonICmarkings          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partSCIcontrols_tok"
              select="          for $token in $partSCIcontrols          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partNoticeType_tok"
              select="          for $token in $partNoticeType          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partSARIdentifier_tok"
              select="          for $token in $partSARIdentifier          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partPocType_tok"
              select="          for $token in $partPocType          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="partNoticeNodeType"
              select="          for $token in $partTags/@ism:noticeType          return             tokenize(normalize-space(string($token)), ' ')"/>
   <xsl:param name="ISM_NSI_EO_APPLIES"
              select="          $ISM_USGOV_RESOURCE and not($ISM_RESOURCE_ELEMENT/@ism:classification = 'U') and $ISM_RESOURCE_CREATE_DATE &gt;= xs:date('1996-04-11') and (some $element in $partTags             satisfies not($element/@ism:classification = 'U') and not($element/@ism:atomicEnergyMarkings))"/>
   <xsl:param name="dcTags"
              select="          for $piece in $disseminationControlsList          return             $piece/text()"/>
   <xsl:param name="dcTagsFound"
              select="          for $token in $dcTags          return             if (index-of($partDisseminationControls_tok, $token) &gt; 0 and (not(index-of($bannerDisseminationControls_tok, $token) &gt; 0))) then                $token             else                null"/>
   <xsl:param name="aeaTags"
              select="          for $piece in $atomicEnergyMarkingsList          return             $piece/text()"/>
   <xsl:param name="aeaTagsFound"
              select="          for $token in $aeaTags          return             if (index-of($partAtomicEnergyMarkings_tok, $token) &gt; 0 and (not(index-of($bannerAtomicEnergyMarkings_tok, $token) &gt; 0))) then                $token             else                null"/>
   <xsl:param name="ACCMRegex" select="'^ACCM-[A-Z0-9\-_]{1,61}$'"/>
   <xsl:param name="nonACCMLeftSet" select="'DS'"/>
   <xsl:param name="nonACCMRightSet" select="'XD,ND,SBU,SBU-NF,LES,LES-NF,SSI,NNPI'"/>
   <xsl:param name="nonACCMLeftSetTok" select="tokenize($nonACCMLeftSet, ',')"/>
   <xsl:param name="nonACCMRightSetTok" select="tokenize($nonACCMRightSet, ',')"/>
   <xsl:param name="decomposableTetraElems"
              select="$cattMappings[@decomposable[. = 'Yes']]"/>
   <xsl:param name="decomposableTetras"
              select="$decomposableTetraElems/catt:TetraToken/text()"/>
   <xsl:param name="countFdrPortions" select="count($partTags[util:containsFDR(.)])"/>
   <xsl:param name="relToCalculatedBannerTokens"
              select="util:calculateCommonCountries($partTags/@ism:releasableTo)"/>
   <xsl:param name="relToActualBannerTokens"
              select="util:expandDecomposableTetras($ISM_RESOURCE_ELEMENT/@ism:releasableTo)"/>
   <xsl:param name="displayToCalculatedBannerTokens"
              select="util:calculateCommonCountries(($partTags/@ism:releasableTo, $partTags/@ism:displayOnlyTo))"/>
   <xsl:param name="displayToActualBannerTokens"
              select="util:expandDecomposableTetras(util:join(($ISM_RESOURCE_ELEMENT/@ism:releasableTo, $ISM_RESOURCE_ELEMENT/@ism:displayOnlyTo)))"/>

   <!--PATTERN ISM-ID-00155-->


	<!--RULE ISM-ID-00155-R1-->
<xsl:template match="*[$ISM_USDOD_RESOURCE                       and not($ISM_DOD_DISTRO_EXEMPT)                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M156">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USDOD_RESOURCE                       and not($ISM_DOD_DISTRO_EXEMPT)                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                       id="ISM-ID-00155-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:noticeType,                      ('DoD-Dist-A', 'DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F', 'DoD-Dist-X'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:noticeType, ('DoD-Dist-A', 'DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F', 'DoD-Dist-X'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00155][Error] All USA documents that do not claim exemption from 
            DoD5230.24 distribution statements must have a distribution statement
            for the entire document.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M156"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M156"/>
   <xsl:template match="@*|node()" priority="-2" mode="M156">
      <xsl:apply-templates select="*" mode="M156"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00157-->


	<!--RULE ISM-ID-00157-R1-->
<xsl:template match="*[$ISM_USDOD_RESOURCE and util:containsAnyOfTheTokens(@ism:noticeType, ('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E'))]"
                 priority="1000"
                 mode="M157">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USDOD_RESOURCE and util:containsAnyOfTheTokens(@ism:noticeType, ('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E'))]"
                       id="ISM-ID-00157-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:noticeReason"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:noticeReason">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [ISM-ID-00157][Error] If
            ISM_USDOD_RESOURCE and: 1. The attribute notice contains one of the [DoD-Dist-B],
            [DoD-Dist-C], [DoD-Dist-D], or [DoD-Dist-E] AND 2. The attribute noticeReason is not
            specified. Human Readable: DoD distribution statements B, C, D , or E all require a
            reason. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M157"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M157"/>
   <xsl:template match="@*|node()" priority="-2" mode="M157">
      <xsl:apply-templates select="*" mode="M157"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00158-->


	<!--RULE ISM-ID-00158-R1-->
<xsl:template match="*[$ISM_USDOD_RESOURCE                         and not($ISM_DOD_DISTRO_EXEMPT)                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and not(@ism:classification='U')]"
                 priority="1000"
                 mode="M158">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USDOD_RESOURCE                         and not($ISM_DOD_DISTRO_EXEMPT)                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and not(@ism:classification='U')]"
                       id="ISM-ID-00158-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="             util:containsAnyOfTheTokens(@ism:noticeType,               ('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:noticeType, ('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [ISM-ID-00158][Error] If ISM_USDOD_RESOURCE and:
               1. not ISM_DOD_DISTRO_EXEMPT AND
               2. attribute classification of ISM_RESOURCE_ELEMENT is not [U] AND
               3. A resource attribute notice does not contain one of [DoD-Dist-B],
                  [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], or [DoD-Dist-F].
                  
            Human Readable: All classified DOD documents that do not claim
            exemption from DoD5230.24 distribution statements
            must use one of DoD distribution statements B, C, D, E, or F.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M158"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M158"/>
   <xsl:template match="@*|node()" priority="-2" mode="M158">
      <xsl:apply-templates select="*" mode="M158"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00161-->


	<!--RULE ISM-ID-00161-R1-->
<xsl:template match="*[$ISM_USDOD_RESOURCE and (util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:noticeType, ('DoD-Dist-A')))        and not (@ism:excludeFromRollup=true())]"
                 priority="1000"
                 mode="M159">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USDOD_RESOURCE and (util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:noticeType, ('DoD-Dist-A')))        and not (@ism:excludeFromRollup=true())]"
                       id="ISM-ID-00161-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(@ism:nonICmarkings)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@ism:nonICmarkings)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
		        [ISM-ID-00161][Error] Distribution statement A (Public Release) is incompatible with any nonICMarkings 
		        if excludeFromRollup is not TRUE.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M159"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M159"/>
   <xsl:template match="@*|node()" priority="-2" mode="M159">
      <xsl:apply-templates select="*" mode="M159"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00162-->


	<!--RULE ISM-ID-00162-R1-->
<xsl:template match="*[$ISM_USDOD_RESOURCE                       and not($ISM_DOD_DISTRO_EXEMPT)                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M160">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USDOD_RESOURCE                       and not($ISM_DOD_DISTRO_EXEMPT)                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                       id="ISM-ID-00162-R1"/>
      <xsl:variable name="matchingTokens"
                    select="           for $token in tokenize(normalize-space(string(@ism:noticeType)), ' ') return             if(matches($token,'^DoD-Dist-[ABCDEFX]$'))             then $token             else null           "/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count($matchingTokens) &lt;= 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count($matchingTokens) &lt;= 1">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00162][Error] All USA documents that do not claim exemption from 
          DoD5230.24 distribution statements must have only 1 distribution statement
          for the entire document.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M160"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M160"/>
   <xsl:template match="@*|node()" priority="-2" mode="M160">
      <xsl:apply-templates select="*" mode="M160"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00227-->


	<!--RULE ISM-ID-00227-R1-->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                        and @ism:noticeType]"
                 priority="1000"
                 mode="M161">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                        and @ism:noticeType]"
                       id="ISM-ID-00227-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $noticeToken in tokenize(normalize-space(string(@ism:noticeType)), ' ') satisfies                     matches($noticeToken, '^DoD-Dist-[ABCDEFX]')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $noticeToken in tokenize(normalize-space(string(@ism:noticeType)), ' ') satisfies matches($noticeToken, '^DoD-Dist-[ABCDEFX]')">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00227][Error] Attribute @noticeType may only appear on the 
            resource node when it contains the values [DoD-Dist-A], [DoD-Dist-B], 
            [DoD-Dist-C], [DoD-Dist-D], [DoD-Dist-E], [DoD-Dist-F], or [DoD-Dist-X].
            
            Human Readable: Documents may only specify a document-level notice if
            it pertains to DoD Distribution.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M161"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M161"/>
   <xsl:template match="@*|node()" priority="-2" mode="M161">
      <xsl:apply-templates select="*" mode="M161"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00237-->


	<!--RULE ISM-ID-00237-R1-->
<xsl:template match="*[$ISM_USDOD_RESOURCE          and util:containsAnyOfTheTokens(@ism:noticeType,            ('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F', 'DoD-Dist-X'))]"
                 priority="1000"
                 mode="M162">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USDOD_RESOURCE          and util:containsAnyOfTheTokens(@ism:noticeType,            ('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F', 'DoD-Dist-X'))]"
                       id="ISM-ID-00237-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:noticeDate"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:noticeDate">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00237][Error] DoD distribution statements B, C, D ,E ,F, and X all require a date.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M162"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M162"/>
   <xsl:template match="@*|node()" priority="-2" mode="M162">
      <xsl:apply-templates select="*" mode="M162"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00238-->


	<!--RULE ISM-ID-00238-R1-->
<xsl:template match="*[$ISM_USDOD_RESOURCE          and util:containsAnyOfTheTokens(@ism:noticeType,            ('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F', 'DoD-Dist-X'))]"
                 priority="1000"
                 mode="M163">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USDOD_RESOURCE          and util:containsAnyOfTheTokens(@ism:noticeType,            ('DoD-Dist-B', 'DoD-Dist-C', 'DoD-Dist-D', 'DoD-Dist-E', 'DoD-Dist-F', 'DoD-Dist-X'))]"
                       id="ISM-ID-00238-R1"/>
      <xsl:variable name="foundNoticeTokens"
                    select="           for $noticeToken in tokenize(normalize-space(string(@ism:noticeType)), ' ') return                if(matches($noticeToken, '^DoD-Dist-[BCDEFX]'))               then $noticeToken               else null"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $noticeToken in $foundNoticeTokens satisfies                  index-of($partPocType_tok, $noticeToken)&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $noticeToken in $foundNoticeTokens satisfies index-of($partPocType_tok, $noticeToken)&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
        	[ISM-ID-00238][Error] DoD distribution statements B, C, D ,E ,F, and X all 
        	require a corresponding point of contact.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M163"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M163"/>
   <xsl:template match="@*|node()" priority="-2" mode="M163">
      <xsl:apply-templates select="*" mode="M163"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00239-->


	<!--RULE ISM-ID-00239-R1-->
<xsl:template match="*[$ISM_USDOD_RESOURCE  and util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:noticeType, ('DoD-Dist-A'))      and not (@ism:excludeFromRollup=true())]"
                 priority="1000"
                 mode="M164">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USDOD_RESOURCE  and util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:noticeType, ('DoD-Dist-A'))      and not (@ism:excludeFromRollup=true())]"
                       id="ISM-ID-00239-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(@ism:disseminationControls)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@ism:disseminationControls)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
			[ISM-ID-00239][Error] If ISM_USDOD_RESOURCE and attribute noticeType of
			ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], then any element 
			which contributes to rollup should not have an attribute
			@disseminationControls present.
			
			Human Readable: Distribution statement A (Public Release) is incompatible 
			with @disseminationControls present for contributing portions.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M164"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M164"/>
   <xsl:template match="@*|node()" priority="-2" mode="M164">
      <xsl:apply-templates select="*" mode="M164"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00240-->


	<!--RULE ISM-ID-00240-R1-->
<xsl:template match="*[$ISM_USDOD_RESOURCE and util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:noticeType, ('DoD-Dist-A'))                  and not (@ism:excludeFromRollup=true())]"
                 priority="1000"
                 mode="M165">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USDOD_RESOURCE and util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:noticeType, ('DoD-Dist-A'))                  and not (@ism:excludeFromRollup=true())]"
                       id="ISM-ID-00240-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(@ism:atomicEnergyMarkings)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@ism:atomicEnergyMarkings)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00240][Error] If ISM_USDOD_RESOURCE and attribute noticeType of
            ISM_RESOURCE_ELEMENT contains the token [DoD-Dist-A], then any element
            which contributes to rolluop should not have an attribute
            @atomicEnergyMarkings present.
            
            Human Readable: Distribution statement A (Public Release) is incompatible 
            with presence of @atomicEnergyMarkings.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M165"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M165"/>
   <xsl:template match="@*|node()" priority="-2" mode="M165">
      <xsl:apply-templates select="*" mode="M165"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00014-->


	<!--RULE ISM-ID-00014-R1-->
<xsl:template match="*[$ISM_NSI_EO_APPLIES                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M166">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_NSI_EO_APPLIES                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                       id="ISM-ID-00014-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:declassDate or @ism:declassEvent or @ism:declassException"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:declassDate or @ism:declassEvent or @ism:declassException">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00014][Error] If ISM_NSI_EO_APPLIES then one or more of the following 
            attributes: declassDate, declassEvent, or declassException must be specified on the ISM_RESOURCE_ELEMENT.
            
            Human Readable: Documents under E.O. 13526 must have declassification instructions included in the 
            classification authority block information.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M166"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M166"/>
   <xsl:template match="@*|node()" priority="-2" mode="M166">
      <xsl:apply-templates select="*" mode="M166"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00016-->


	<!--RULE ISM-ID-00016-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:classification='U']"
                 priority="1000"
                 mode="M167">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:classification='U']"
                       id="ISM-ID-00016-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(                     @ism:classificationReason                  or @ism:classifiedBy                  or @ism:declassDate                  or @ism:declassEvent                  or @ism:declassException                  or @ism:derivativelyClassifiedBy                  or @ism:derivedFrom                  or @ism:SARIdentifier                 or @ism:SCIcontrols                 )"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not( @ism:classificationReason or @ism:classifiedBy or @ism:declassDate or @ism:declassEvent or @ism:declassException or @ism:derivativelyClassifiedBy or @ism:derivedFrom or @ism:SARIdentifier or @ism:SCIcontrols )">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00016][Error] If ISM_USGOV_RESOURCE and attribute 
          classification has a value of [U], then attributes classificationReason,
          classifiedBy, derivativelyClassifiedBy, declassDate, declassEvent, 
          declassException, derivedFrom, SARIdentifier, or 
          SCIcontrols must not be specified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M167"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M167"/>
   <xsl:template match="@*|node()" priority="-2" mode="M167">
      <xsl:apply-templates select="*" mode="M167"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00017-->


	<!--RULE ISM-ID-00017-R1-->
<xsl:template match="*[$ISM_NSI_EO_APPLIES and @ism:classifiedBy]"
                 priority="1000"
                 mode="M168">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_NSI_EO_APPLIES and @ism:classifiedBy]"
                       id="ISM-ID-00017-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:classificationReason"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:classificationReason">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00017][Error] If ISM_NSI_EO_APPLIES and attribute 
        	classifiedBy is specified, then attribute classificationReason must 
        	be specified. 
        	
        	Human Readable: Documents under E.O. 13526 containing 
        	Originally Classified data require a classification reason to be
        	identified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M168"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M168"/>
   <xsl:template match="@*|node()" priority="-2" mode="M168">
      <xsl:apply-templates select="*" mode="M168"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00026-->


	<!--RULE ValuesOrderedAccordingToCve-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:disseminationControls]"
                 priority="1000"
                 mode="M169">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:disseminationControls]"
                       id="ValuesOrderedAccordingToCve-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count(tokenize(util:unsortedValues(@ism:disseminationControls, $disseminationControlsList),' ')) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(util:unsortedValues(@ism:disseminationControls, $disseminationControlsList),' ')) = 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'     [ISM-ID-00026][Error] If ISM_USGOV_RESOURCE and attribute disseminationControls     is specified, then each of its values must be ordered in accordance with      CVEnumISMDissem.xml.     '"/>
                  <xsl:text/>
      The following values are out of order [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:disseminationControls, $disseminationControlsList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:disseminationControls"/>
                  <xsl:text/>]
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M169"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M169"/>
   <xsl:template match="@*|node()" priority="-2" mode="M169">
      <xsl:apply-templates select="*" mode="M169"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00028-->


	<!--RULE ISM-ID-00028-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC', 'EYES'))]"
                 priority="1000"
                 mode="M170">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC', 'EYES'))]"
                       id="ISM-ID-00028-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:classification=('TS', 'S', 'C')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:classification=('TS', 'S', 'C')">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00028][Error] If ISM_USGOV_RESOURCE and attribute 
            disseminationControls contains the name token [OC] or [EYES], 
            then attribute classification must have a value of [TS], [S], or [C].
            
            Human Readable: Portions marked for ORCON or EYES ONLY dissemination 
            in a USA document must be CONFIDENTIAL, SECRET, or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M170"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M170"/>
   <xsl:template match="@*|node()" priority="-2" mode="M170">
      <xsl:apply-templates select="*" mode="M170"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00030-->


	<!--RULE ISM-ID-00030-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))]"
                 priority="1000"
                 mode="M171">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))]"
                       id="ISM-ID-00030-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:classification='U'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:classification='U'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00030][Error] If ISM_USGOV_RESOURCE and attribute 
        	disseminationControls contains the name token [FOUO], then attribute
        	classification must have a value of [U].
        	
        	Human Readable: Portions marked for FOUO dissemination in a USA document
        	must be classified UNCLASSIFIED.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M171"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M171"/>
   <xsl:template match="@*|node()" priority="-2" mode="M171">
      <xsl:apply-templates select="*" mode="M171"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00031-->


	<!--RULE ISM-ID-00031-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('REL', 'EYES'))]"
                 priority="1000"
                 mode="M172">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('REL', 'EYES'))]"
                       id="ISM-ID-00031-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:releasableTo"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:releasableTo">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00031][Error] If ISM_USGOV_RESOURCE and attribute 
        	disseminationControls contains the name token [REL] or [EYES], then 
        	attribute releasableTo must be specified.
        	
        	Human Readable: USA documents containing REL TO or EYES ONLY 
        	dissemination must specify to which countries the document is releasable.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M172"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M172"/>
   <xsl:template match="@*|node()" priority="-2" mode="M172">
      <xsl:apply-templates select="*" mode="M172"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00032-->


	<!--RULE ISM-ID-00032-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('REL', 'EYES')))]"
                 priority="1000"
                 mode="M173">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('REL', 'EYES')))]"
                       id="ISM-ID-00032-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(@ism:releasableTo)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@ism:releasableTo)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00032][Error] If ISM_USGOV_RESOURCE and attribute 
            disseminationControls is not specified, or is specified and does not 
            contain the name token [REL] or [EYES], then attribute releasableTo 
            must not be specified.
            
            Human Readable: USA documents must only specify to which countries it is 
            authorized for release if dissemination information contains 
            REL TO or EYES ONLY data. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M173"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M173"/>
   <xsl:template match="@*|node()" priority="-2" mode="M173">
      <xsl:apply-templates select="*" mode="M173"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00033-->


	<!--RULE MutuallyExclusiveAttributeValues-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                                    and util:containsAnyOfTheTokens(@ism:disseminationControls, ('REL', 'EYES', 'NF'))]"
                 priority="1000"
                 mode="M174">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                                    and util:containsAnyOfTheTokens(@ism:disseminationControls, ('REL', 'EYES', 'NF'))]"
                       id="MutuallyExclusiveAttributeValues-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( for $token in tokenize(normalize-space(string(@ism:disseminationControls)),' ') return  if($token = ('REL', 'EYES', 'NF')) then 1 else null ) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( for $token in tokenize(normalize-space(string(@ism:disseminationControls)),' ') return if($token = ('REL', 'EYES', 'NF')) then 1 else null ) = 1">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00033][Error] If ISM_USGOV_RESOURCE, then tokens [REL], [EYES]    and [NF] are mutually exclusive for attribute disseminationControls.   '"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M174"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M174"/>
   <xsl:template match="@*|node()" priority="-2" mode="M174">
      <xsl:apply-templates select="*" mode="M174"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00035-->


	<!--RULE ValuesOrderedAccordingToCveWhenContributesToRollupACCM-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:nonICmarkings]"
                 priority="1000"
                 mode="M175">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:nonICmarkings]"
                       id="ValuesOrderedAccordingToCveWhenContributesToRollupACCM-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="if (util:contributesToRollup(.)) then count(tokenize(util:unsortedValues(@ism:nonICmarkings, $nonICmarkingsList),' '))=0 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (util:contributesToRollup(.)) then count(tokenize(util:unsortedValues(@ism:nonICmarkings, $nonICmarkingsList),' '))=0 else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00035][Error] If ISM_USGOV_RESOURCE and attribute nonICmarkings is specified and contributes to rollup, its values must be ordered in accordance with CVEnumISMNonIC.xml.'"/>
                  <xsl:text/>
      The following values [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:nonICmarkings, $nonICmarkingsList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:nonICmarkings"/>
                  <xsl:text/>] that contribute to rollup are out of order with respect to its CVE.
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="if (not(util:contributesToRollup(.))) then count(tokenize(util:unorderedValues(tokenize(normalize-space(string(util:getStringFromSequenceWithoutRegexValues(tokenize(normalize-space(string(@ism:nonICmarkings)), ' '), $ACCMRegex))), ' '), tokenize(normalize-space(string(util:getStringFromSequenceWithoutRegexValues($nonICmarkingsList, $ACCMRegex))), ' ')),' '))=0 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (not(util:contributesToRollup(.))) then count(tokenize(util:unorderedValues(tokenize(normalize-space(string(util:getStringFromSequenceWithoutRegexValues(tokenize(normalize-space(string(@ism:nonICmarkings)), ' '), $ACCMRegex))), ' '), tokenize(normalize-space(string(util:getStringFromSequenceWithoutRegexValues($nonICmarkingsList, $ACCMRegex))), ' ')),' '))=0 else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00035][Error] If ISM_USGOV_RESOURCE and attribute nonICmarkings is specified but does not contribute to rollup, its non-ACCM values must be ordered in accordance with CVEnumISMNonIC.xml.'"/>
                  <xsl:text/>
      The following non-ACCM values [<xsl:text/>
                  <xsl:value-of select="util:unorderedValues(tokenize(normalize-space(string(util:getStringFromSequenceWithoutRegexValues(tokenize(normalize-space(string(@ism:nonICmarkings)), ' '), $ACCMRegex))), ' '), tokenize(normalize-space(string(util:getStringFromSequenceWithoutRegexValues($nonICmarkingsList, $ACCMRegex))), ' '))"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:nonICmarkings"/>
                  <xsl:text/>] that does not contribute to rollup are out of order with respect to its CVE.
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="if (not(util:contributesToRollup(.))) then count(tokenize(util:nonalphabeticValues(tokenize(normalize-space(string(util:getStringFromSequenceWithOnlyRegexValues(tokenize(normalize-space(string(@ism:nonICmarkings)), ' '), $ACCMRegex))), ' ')),' '))=0 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (not(util:contributesToRollup(.))) then count(tokenize(util:nonalphabeticValues(tokenize(normalize-space(string(util:getStringFromSequenceWithOnlyRegexValues(tokenize(normalize-space(string(@ism:nonICmarkings)), ' '), $ACCMRegex))), ' ')),' '))=0 else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00035][Error] If ISM_USGOV_RESOURCE and attribute nonICmarkings is specified but does not contribute to rollup, its ACCM values must be ordered alphabetically.'"/>
                  <xsl:text/>
      The following ACCM values [<xsl:text/>
                  <xsl:value-of select="util:nonalphabeticValues(tokenize(normalize-space(string(util:getStringFromSequenceWithOnlyRegexValues(tokenize(normalize-space(string(@ism:nonICmarkings)), ' '), $ACCMRegex))), ' '))"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:nonICmarkings"/>
                  <xsl:text/>] that does not contribute to rollup are not in the expected alphabetical order.
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="if (not(util:contributesToRollup(.))) then count(tokenize(util:relativeOrderBetweenACCMAndNonACCMWhenExcludeFromRollup(tokenize(normalize-space(string(@ism:nonICmarkings)), ' ')),' '))=0 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (not(util:contributesToRollup(.))) then count(tokenize(util:relativeOrderBetweenACCMAndNonACCMWhenExcludeFromRollup(tokenize(normalize-space(string(@ism:nonICmarkings)), ' ')),' '))=0 else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00035][Error] If ISM_USGOV_RESOURCE and attribute nonICmarkings is specified but does not contribute to rollup, its ACCM values should be in the correct relative order to the non-ACCM values'"/>
                  <xsl:text/>
      The following non-ACCM values [<xsl:text/>
                  <xsl:value-of select="util:relativeOrderBetweenACCMAndNonACCMWhenExcludeFromRollup(tokenize(normalize-space(string(@ism:nonICmarkings)), ' '))"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:nonICmarkings"/>
                  <xsl:text/>] that does not contribute to rollup are not in the correct relative order to the ACCM values [<xsl:text/>
                  <xsl:value-of select="util:getStringFromSequence(tokenize(normalize-space(string(util:getStringFromSequenceWithOnlyRegexValues(tokenize(normalize-space(string(@ism:nonICmarkings)), ' '), $ACCMRegex))), ' '))"/>
                  <xsl:text/>].
      The ACCM values exist between the LEFT set of non-ACCMs [<xsl:text/>
                  <xsl:value-of select="$nonACCMLeftSetTok"/>
                  <xsl:text/>] and the RIGHT set of non-ACCMs [<xsl:text/>
                  <xsl:value-of select="$nonACCMRightSetTok"/>
                  <xsl:text/>].
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M175"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M175"/>
   <xsl:template match="@*|node()" priority="-2" mode="M175">
      <xsl:apply-templates select="*" mode="M175"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00037-->


	<!--RULE ISM-ID-00037-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:resourceElement=true() and                    util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SBU', 'SBU-NF'))]"
                 priority="1000"
                 mode="M176">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:resourceElement=true() and                    util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SBU', 'SBU-NF'))]"
                       id="ISM-ID-00037-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:classification='U'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:classification='U'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ISM-ID-00037][Error] When
            ISM_USGOV_RESOURCE and @ism:nonICmarkings contains [SBU] or [SBU-NF] then
            @ism:classification must equal [U].</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M176"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M176"/>
   <xsl:template match="@*|node()" priority="-2" mode="M176">
      <xsl:apply-templates select="*" mode="M176"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00038-->


	<!--RULE MutuallyExclusiveAttributeValues-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE   and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD', 'ND', 'SBU', 'SBU-NF'))]"
                 priority="1000"
                 mode="M177">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE   and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD', 'ND', 'SBU', 'SBU-NF'))]"
                       id="MutuallyExclusiveAttributeValues-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( for $token in tokenize(normalize-space(string(@ism:nonICmarkings)),' ') return  if($token = ('XD', 'ND', 'SBU', 'SBU-NF')) then 1 else null ) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( for $token in tokenize(normalize-space(string(@ism:nonICmarkings)),' ') return if($token = ('XD', 'ND', 'SBU', 'SBU-NF')) then 1 else null ) = 1">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00038][Error] If ISM_USGOV_RESOURCE, then the tokens    [XD], [ND], [SBU], and [SBU-NF] are mutually exclusive for attribute nonICmarkings.      Human Readable: USA documents must not specify [XD], [ND], [SBU], and/or [SBU-NF] commingled on a single element.   '"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M177"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M177"/>
   <xsl:template match="@*|node()" priority="-2" mode="M177">
      <xsl:apply-templates select="*" mode="M177"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00040-->


	<!--RULE ValidateValueExistenceInList-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                                      and util:containsAnyOfTheTokens(@ism:ownerProducer, ('USA'))]"
                 priority="1000"
                 mode="M178">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                                      and util:containsAnyOfTheTokens(@ism:ownerProducer, ('USA'))]"
                       id="ValidateValueExistenceInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="some $token in $classificationUSList satisfies $token = @ism:classification"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $token in $classificationUSList satisfies $token = @ism:classification">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00040][Error] If ISM_USGOV_RESOURCE and attribute    ownerProducer contains [USA] then attribute classification must have a   value in CVEnumISMClassificationUS.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M178"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M178"/>
   <xsl:template match="@*|node()" priority="-2" mode="M178">
      <xsl:apply-templates select="*" mode="M178"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00041-->


	<!--RULE ValuesOrderedAccordingToCve-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:releasableTo]"
                 priority="1000"
                 mode="M179">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:releasableTo]"
                       id="ValuesOrderedAccordingToCve-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count(tokenize(util:unsortedValues(@ism:releasableTo, $releasableToList),' ')) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(util:unsortedValues(@ism:releasableTo, $releasableToList),' ')) = 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'     [ISM-ID-00041][Error] If ISM_USGOV_RESOURCE and attribute releasableTo is specified,      then each of its values must be ordered in accordance with CVEnumISMCATRelTo.xml.     '"/>
                  <xsl:text/>
      The following values are out of order [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:releasableTo, $releasableToList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:releasableTo"/>
                  <xsl:text/>]
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M179"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M179"/>
   <xsl:template match="@*|node()" priority="-2" mode="M179">
      <xsl:apply-templates select="*" mode="M179"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00042-->


	<!--RULE ValuesOrderedAccordingToCveWhenContributesToRollup-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:SCIcontrols]"
                 priority="1000"
                 mode="M180">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:SCIcontrols]"
                       id="ValuesOrderedAccordingToCveWhenContributesToRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="if (util:contributesToRollup(.)) then count(tokenize(util:unsortedValues(@ism:SCIcontrols, $SCIcontrolsList),' '))=0 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (util:contributesToRollup(.)) then count(tokenize(util:unsortedValues(@ism:SCIcontrols, $SCIcontrolsList),' '))=0 else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00042][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols is specified and contributes to rollup, its values must be ordered in accordance with CVEnumISMSCIControls.xml.'"/>
                  <xsl:text/>
      The following values [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:SCIcontrols, $SCIcontrolsList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:SCIcontrols"/>
                  <xsl:text/>] that contribute to rollup are out of order with respect to its CVE.
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="if (not(util:contributesToRollup(.))) then count(tokenize(util:nonalphabeticValues(tokenize(normalize-space(string(@ism:SCIcontrols)), ' ')),' '))=0 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (not(util:contributesToRollup(.))) then count(tokenize(util:nonalphabeticValues(tokenize(normalize-space(string(@ism:SCIcontrols)), ' ')),' '))=0 else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00042][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols is specified but does not contribute to rollup, its values must be ordered alphabetically.'"/>
                  <xsl:text/>
      The following values [<xsl:text/>
                  <xsl:value-of select="util:nonalphabeticValues(tokenize(normalize-space(string(@ism:SCIcontrols)), ' '))"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:SCIcontrols"/>
                  <xsl:text/>] that does not contribute to rollup are not in the expected alphabetical order.
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M180"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M180"/>
   <xsl:template match="@*|node()" priority="-2" mode="M180">
      <xsl:apply-templates select="*" mode="M180"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00043-->


	<!--RULE ISM-ID-00043-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI'))]"
                 priority="1000"
                 mode="M181">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI'))]"
                       id="ISM-ID-00043-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S', 'C'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S', 'C'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00043][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols
            contains the name token [SI], then attribute classification must have
            a value of [TS], [S], or [C].
            
            Human Readable: A USA document containing Special Intelligence (SI) 
            data must be classified CONFIDENTIAL, SECRET, or TOP SECRET. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M181"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M181"/>
   <xsl:template match="@*|node()" priority="-2" mode="M181">
      <xsl:apply-templates select="*" mode="M181"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00044-->


	<!--RULE ISM-ID-00044-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^SI-G$'))]"
                 priority="1000"
                 mode="M182">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^SI-G$'))]"
                       id="ISM-ID-00044-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:classification, ('TS'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:classification, ('TS'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00044][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains a name
            token with [SI-G], then attribute classification must have a value of [TS]. Human
            Readable: A USA document containing Special Intelligence (SI) GAMMA compartment data
            must be classified TOP SECRET. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M182"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M182"/>
   <xsl:template match="@*|node()" priority="-2" mode="M182">
      <xsl:apply-templates select="*" mode="M182"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00045-->


	<!--RULE ISM-ID-00045-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^SI-G$'))]"
                 priority="1000"
                 mode="M183">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^SI-G$'))]"
                       id="ISM-ID-00045-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00045][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols
            contains a name token starting with [SI-G], then attribute
            disseminationControls must contain the name token [OC].
            
            Human Readable: A USA document containing Special Intelligence (SI)
            GAMMA compartment data must be marked for ORIGINATOR CONTROLLED 
            dissemination.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M183"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M183"/>
   <xsl:template match="@*|node()" priority="-2" mode="M183">
      <xsl:apply-templates select="*" mode="M183"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00047-->


	<!--RULE ISM-ID-00047-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK'))]"
                 priority="1000"
                 mode="M184">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK'))]"
                       id="ISM-ID-00047-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00047][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols
            contains the name token [TK], then attribute classification must have
            a value of [TS] or [S].
            
            Human Readable: A USA document containing TALENT KEYHOLE data must
            be classified SECRET or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M184"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M184"/>
   <xsl:template match="@*|node()" priority="-2" mode="M184">
      <xsl:apply-templates select="*" mode="M184"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00048-->


	<!--RULE ISM-ID-00048-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS'))]"
                 priority="1000"
                 mode="M185">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS'))]"
                       id="ISM-ID-00048-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S', 'C'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S', 'C'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00048][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols
            contains the name token [HCS], then attribute classification must have
            a value of [TS], [S], or [C].
            
            Human Readable: A USA document containing HCS data must be classified
            CONFIDENTIAL, SECRET, or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M185"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M185"/>
   <xsl:template match="@*|node()" priority="-2" mode="M185">
      <xsl:apply-templates select="*" mode="M185"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00049-->


	<!--RULE ISM-ID-00049-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS'))]"
                 priority="1000"
                 mode="M186">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS'))]"
                       id="ISM-ID-00049-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00049][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols
            contains the name token [HCS], then attribute disseminationControls
            must contain the name token [NF].
            
            Human Readable: A USA document containing HCS data must be marked
            for NO FOREIGN dissemination.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M186"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M186"/>
   <xsl:template match="@*|node()" priority="-2" mode="M186">
      <xsl:apply-templates select="*" mode="M186"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00056-->


	<!--RULE ISM-ID-00056-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and normalize-space(string(@ism:classification)) = 'U']"
                 priority="1000"
                 mode="M187">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and normalize-space(string(@ism:classification)) = 'U']"
                       id="ISM-ID-00056-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="                 every $ele in $partTags                     satisfies not(util:containsAnyOfTheTokens($ele/@ism:classification, ('C', 'S', 'TS', 'R')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $ele in $partTags satisfies not(util:containsAnyOfTheTokens($ele/@ism:classification, ('C', 'S', 'TS', 'R')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [ISM-ID-00056][Error] If ISM_USGOV_RESOURCE and attribute classification
            of ISM_RESOURCE_ELEMENT has a value of [U] then no element meeting ISM_CONTRIBUTES in
            the document may have a classification attribute of [C], [S], [TS], or [R]. Human
            Readable: USA UNCLASSIFIED documents can't have portion markings with the classification
            TOP SECRET, SECRET, CONFIDENTIAL, or RESTRICTED data. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M187"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M187"/>
   <xsl:template match="@*|node()" priority="-2" mode="M187">
      <xsl:apply-templates select="*" mode="M187"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00058-->


	<!--RULE ISM-ID-00058-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and normalize-space(string(@ism:classification))='C']"
                 priority="1000"
                 mode="M188">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and normalize-space(string(@ism:classification))='C']"
                       id="ISM-ID-00058-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $ele in $partTags satisfies                 not(util:containsAnyOfTheTokens($ele/@ism:classification, ('S', 'TS')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $ele in $partTags satisfies not(util:containsAnyOfTheTokens($ele/@ism:classification, ('S', 'TS')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00058][Error] USA CONFIDENTIAL documents can't have TOP SECRET or SECRET data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M188"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M188"/>
   <xsl:template match="@*|node()" priority="-2" mode="M188">
      <xsl:apply-templates select="*" mode="M188"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00059-->


	<!--RULE ISM-ID-00059-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and normalize-space(string(@ism:classification))='S']"
                 priority="1000"
                 mode="M189">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and normalize-space(string(@ism:classification))='S']"
                       id="ISM-ID-00059-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $ele in $partTags satisfies                 not(util:containsAnyOfTheTokens($ele/@ism:classification, ('TS')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $ele in $partTags satisfies not(util:containsAnyOfTheTokens($ele/@ism:classification, ('TS')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00059][Error] USA SECRET documents can't have TOP SECRET data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M189"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M189"/>
   <xsl:template match="@*|node()" priority="-2" mode="M189">
      <xsl:apply-templates select="*" mode="M189"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00064-->


	<!--RULE ISM-ID-00064-R1-->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M190">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                       id="ISM-ID-00064-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="             if(not($ISM_USGOV_RESOURCE)) then true() else             if(not(empty($partFGIsourceOpen)))                  then ($bannerFGIsourceOpen                        or $bannerFGIsourceProtected)                  else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_USGOV_RESOURCE)) then true() else if(not(empty($partFGIsourceOpen))) then ($bannerFGIsourceOpen or $bannerFGIsourceProtected) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [ISM-ID-00064][Error] USA documents having FGI Open data must have FGI
            Open or FGI Protected at the resource level. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M190"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M190"/>
   <xsl:template match="@*|node()" priority="-2" mode="M190">
      <xsl:apply-templates select="*" mode="M190"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00065-->


	<!--RULE ISM-ID-00065-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and not(empty($partFGIsourceProtected))]"
                 priority="1000"
                 mode="M191">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and not(empty($partFGIsourceProtected))]"
                       id="ISM-ID-00065-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:FGIsourceProtected"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:FGIsourceProtected">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00065][Error] USA documents having FGI Protected data must have FGI Protected at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M191"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M191"/>
   <xsl:template match="@*|node()" priority="-2" mode="M191">
      <xsl:apply-templates select="*" mode="M191"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00066-->


	<!--RULE ISM-ID-00066-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE          and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                                  and index-of($dcTagsFound,'FOUO') &gt; 0                                  and util:containsAnyOfTheTokens(@ism:classification, ('U'))                                  and count($partNonICmarkings_tok) = 0                                   and util:containsOnlyTheTokens(string-join($partDisseminationControls, ' '), ('REL', 'RELIDO', 'NF', 'EYES', 'DISPLAYONLY', 'FOUO'))]"
                 priority="1000"
                 mode="M192">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE          and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                                  and index-of($dcTagsFound,'FOUO') &gt; 0                                  and util:containsAnyOfTheTokens(@ism:classification, ('U'))                                  and count($partNonICmarkings_tok) = 0                                   and util:containsOnlyTheTokens(string-join($partDisseminationControls, ' '), ('REL', 'RELIDO', 'NF', 'EYES', 'DISPLAYONLY', 'FOUO'))]"
                       id="ISM-ID-00066-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00066][Error] USA Unclassified documents having FOUO data, no non IC Markings, and only 
            contains dissemination controls [REL], [RELIDO], [NF], [DISPLAYONLY], [EYES], and [FOUO] must have 
            FOUO at the resource level. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M192"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M192"/>
   <xsl:template match="@*|node()" priority="-2" mode="M192">
      <xsl:apply-templates select="*" mode="M192"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00067-->


	<!--RULE AttributeContributesToRollup-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('OC')))]"
                 priority="1000"
                 mode="M193">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('OC')))]"
                       id="AttributeContributesToRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00067][Error] USA documents having ORCON data must have ORCON at the resource level.'"/>
                  <xsl:text/> 
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M193"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M193"/>
   <xsl:template match="@*|node()" priority="-2" mode="M193">
      <xsl:apply-templates select="*" mode="M193"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00068-->


	<!--RULE AttributeContributesToRollup-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('IMC')))]"
                 priority="1000"
                 mode="M194">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('IMC')))]"
                       id="AttributeContributesToRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('IMC'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('IMC'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00068][Error] USA documents having IMCON data must have IMCON at the resource level.'"/>
                  <xsl:text/> 
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M194"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M194"/>
   <xsl:template match="@*|node()" priority="-2" mode="M194">
      <xsl:apply-templates select="*" mode="M194"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00070-->


	<!--RULE AttributeContributesToRollup-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('NF')))]"
                 priority="1000"
                 mode="M195">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('NF')))]"
                       id="AttributeContributesToRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00070][Error] USA documents having NF data must have NF at the resource level.'"/>
                  <xsl:text/> 
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M195"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M195"/>
   <xsl:template match="@*|node()" priority="-2" mode="M195">
      <xsl:apply-templates select="*" mode="M195"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00071-->


	<!--RULE AttributeContributesToRollup-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('PR')))]"
                 priority="1000"
                 mode="M196">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('PR')))]"
                       id="AttributeContributesToRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('PR'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('PR'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00071][Error] USA documents having PROPIN data must have PROPIN at the resource level.'"/>
                  <xsl:text/> 
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M196"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M196"/>
   <xsl:template match="@*|node()" priority="-2" mode="M196">
      <xsl:apply-templates select="*" mode="M196"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00072-->


	<!--RULE AttributeContributesToRollup-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('RD')))]"
                 priority="1000"
                 mode="M197">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('RD')))]"
                       id="AttributeContributesToRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00072][Error] USA documents having Restricted Data (RD) must have RD at the resource level.'"/>
                  <xsl:text/> 
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M197"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M197"/>
   <xsl:template match="@*|node()" priority="-2" mode="M197">
      <xsl:apply-templates select="*" mode="M197"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00073-->


	<!--RULE AttributeContributesToRollup-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('RD-CNWDI')))]"
                 priority="1000"
                 mode="M198">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('RD-CNWDI')))]"
                       id="AttributeContributesToRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD-CNWDI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD-CNWDI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00073][Error] USA documents having Restricted CNWDI Data must have Restricted CNWDI Data at the resource level.'"/>
                  <xsl:text/> 
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M198"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M198"/>
   <xsl:template match="@*|node()" priority="-2" mode="M198">
      <xsl:apply-templates select="*" mode="M198"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00074-->


	<!--RULE ISM-ID-00074-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M199">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                       id="ISM-ID-00074-R1"/>
      <xsl:variable name="matchingTokens"
                    select="         for $token in $partAtomicEnergyMarkings_tok return           if(matches($token,'^RD-SG-[1-9][0-9]?$'))           then $token           else null         "/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $token in $matchingTokens satisfies                             index-of($bannerAtomicEnergyMarkings_tok, $token) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $token in $matchingTokens satisfies index-of($bannerAtomicEnergyMarkings_tok, $token) &gt; 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00074][Error] USA documents having Restricted SIGMA-## Data must have the same Restricted SIGMA-## Data at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M199"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M199"/>
   <xsl:template match="@*|node()" priority="-2" mode="M199">
      <xsl:apply-templates select="*" mode="M199"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00075-->


	<!--RULE AttributeContributesToRollupWithException-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and not(some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('RD'))                       )                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('FRD'))                       )]"
                 priority="1000"
                 mode="M200">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and not(some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('RD'))                       )                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('FRD'))                       )]"
                       id="AttributeContributesToRollupWithException-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('FRD'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('FRD'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00075][Error] USA documents having Formerly Restricted Data (FRD) and not having Restricted Data (RD) must have FRD at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M200"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M200"/>
   <xsl:template match="@*|node()" priority="-2" mode="M200">
      <xsl:apply-templates select="*" mode="M200"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00077-->


	<!--RULE ISM-ID-00077-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and not(util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:atomicEnergyMarkings, ('RD')))]"
                 priority="1000"
                 mode="M201">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and not(util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:atomicEnergyMarkings, ('RD')))]"
                       id="ISM-ID-00077-R1"/>
      <xsl:variable name="matchingTokens"
                    select="           for $token in $partAtomicEnergyMarkings_tok return             if(matches($token,'^FRD-SG-[1-9][0-9]?$'))             then $token             else null           "/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $token in $matchingTokens satisfies                     index-of($bannerAtomicEnergyMarkings_tok, $token) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $token in $matchingTokens satisfies index-of($bannerAtomicEnergyMarkings_tok, $token) &gt; 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00077][Error] USA documents having Formerly Restricted SIGMA-## Data and not having RD data must have the same Formerly Restricted SIGMA-## Data at 
            the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M201"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M201"/>
   <xsl:template match="@*|node()" priority="-2" mode="M201">
      <xsl:apply-templates select="*" mode="M201"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00078-->


	<!--RULE AttributeContributesToRollupWithClassification-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE      and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)      and util:containsAnyOfTheTokens(@ism:classification, ( 'U' ))     and (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('DCNI')))]"
                 priority="1000"
                 mode="M202">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE      and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)      and util:containsAnyOfTheTokens(@ism:classification, ( 'U' ))     and (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('DCNI')))]"
                       id="AttributeContributesToRollupWithClassification-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('DCNI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('DCNI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00078][Error] Unclassified USA documents having DCNI Data must have DCNI at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M202"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M202"/>
   <xsl:template match="@*|node()" priority="-2" mode="M202">
      <xsl:apply-templates select="*" mode="M202"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00079-->


	<!--RULE AttributeContributesToRollupWithClassification-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE      and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)      and util:containsAnyOfTheTokens(@ism:classification, ( 'U' ))     and (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('UCNI')))]"
                 priority="1000"
                 mode="M203">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE      and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)      and util:containsAnyOfTheTokens(@ism:classification, ( 'U' ))     and (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('UCNI')))]"
                       id="AttributeContributesToRollupWithClassification-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('UCNI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('UCNI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00079][Error] Unclassified USA documents having UCNI Data must have UCNI at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M203"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M203"/>
   <xsl:template match="@*|node()" priority="-2" mode="M203">
      <xsl:apply-templates select="*" mode="M203"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00080-->


	<!--RULE AttributeContributesToRollup-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('DSEN')))]"
                 priority="1000"
                 mode="M204">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('DSEN')))]"
                       id="AttributeContributesToRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('DSEN'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('DSEN'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00080][Error] USA documents having DSEN Data must have DSEN at the resource level.'"/>
                  <xsl:text/> 
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M204"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M204"/>
   <xsl:template match="@*|node()" priority="-2" mode="M204">
      <xsl:apply-templates select="*" mode="M204"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00081-->


	<!--RULE AttributeContributesToRollup-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('FISA')))]"
                 priority="1000"
                 mode="M205">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('FISA')))]"
                       id="AttributeContributesToRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('FISA'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('FISA'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00081][Error] USA documents having FISA Data must have FISA at the resource level.'"/>
                  <xsl:text/> 
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M205"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M205"/>
   <xsl:template match="@*|node()" priority="-2" mode="M205">
      <xsl:apply-templates select="*" mode="M205"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00084-->


	<!--RULE AttributeContributesToRollupWithClassification-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE      and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)      and util:containsAnyOfTheTokens(@ism:classification, ( 'U' ))     and (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('DS')))]"
                 priority="1000"
                 mode="M206">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE      and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)      and util:containsAnyOfTheTokens(@ism:classification, ( 'U' ))     and (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('DS')))]"
                       id="AttributeContributesToRollupWithClassification-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('DS'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('DS'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00084][Error] Unclassified USA documents having DS Data must have DS at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M206"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M206"/>
   <xsl:template match="@*|node()" priority="-2" mode="M206">
      <xsl:apply-templates select="*" mode="M206"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00085-->


	<!--RULE AttributeContributesToRollupWithException-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and not(some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('ND'))                       )                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('XD'))                       )]"
                 priority="1000"
                 mode="M207">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and not(some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('ND'))                       )                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('XD'))                       )]"
                       id="AttributeContributesToRollupWithException-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00085][Error] USA documents having XD Data and not having ND must have XD at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M207"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M207"/>
   <xsl:template match="@*|node()" priority="-2" mode="M207">
      <xsl:apply-templates select="*" mode="M207"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00086-->


	<!--RULE AttributeContributesToRollup-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('ND')))]"
                 priority="1000"
                 mode="M208">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('ND')))]"
                       id="AttributeContributesToRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('ND'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('ND'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00086][Error] USA documents having ND Data must have ND at the resource level.'"/>
                  <xsl:text/> 
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M208"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M208"/>
   <xsl:template match="@*|node()" priority="-2" mode="M208">
      <xsl:apply-templates select="*" mode="M208"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00087-->


	<!--RULE ISM-ID-00087-R1-->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M209">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                       id="ISM-ID-00087-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="                 if (not($ISM_USGOV_RESOURCE)) then                     true()                 else                     if (index-of($partNonICmarkings_tok, 'SBU-NF') &gt; 0 and not($bannerClassification = 'U')) then                         (index-of($bannerDisseminationControls_tok, 'NF') &gt; 0)                     else                         true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (not($ISM_USGOV_RESOURCE)) then true() else if (index-of($partNonICmarkings_tok, 'SBU-NF') &gt; 0 and not($bannerClassification = 'U')) then (index-of($bannerDisseminationControls_tok, 'NF') &gt; 0) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [ISM-ID-00087][Error] Classified USA documents having SBU-NF Data must
            have NF at the resource level. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M209"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M209"/>
   <xsl:template match="@*|node()" priority="-2" mode="M209">
      <xsl:apply-templates select="*" mode="M209"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00088-->


	<!--RULE ISM-ID-00088-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and @ism:releasableTo]"
                 priority="1000"
                 mode="M210">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and @ism:releasableTo]"
                       id="ISM-ID-00088-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $portion in $partTags satisfies ( ($portion/@ism:classification='U' and not($portion/@ism:disseminationControls) ) or                           $portion/@ism:releasableTo[normalize-space()])"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $portion in $partTags satisfies ( ($portion/@ism:classification='U' and not($portion/@ism:disseminationControls) ) or $portion/@ism:releasableTo[normalize-space()])">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ISM-ID-00088][Error] USA documents having any classified portion that is not Releasable or
            having unclassified portions with disseminationControls that are not [REL] cannot be REL at the resource
            level.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M210"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M210"/>
   <xsl:template match="@*|node()" priority="-2" mode="M210">
      <xsl:apply-templates select="*" mode="M210"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00090-->


	<!--RULE ISM-ID-00090-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and index-of($partDisseminationControls_tok, 'REL') &gt; 0]"
                 priority="1000"
                 mode="M211">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and index-of($partDisseminationControls_tok, 'REL') &gt; 0]"
                       id="ISM-ID-00090-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('EYES')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('EYES')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00090][Error] USA documents with any portion that is REL must not be EYES at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M211"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M211"/>
   <xsl:template match="@*|node()" priority="-2" mode="M211">
      <xsl:apply-templates select="*" mode="M211"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00095-->


	<!--RULE ValuesOrderedAccordingToCve-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:FGIsourceOpen]"
                 priority="1000"
                 mode="M212">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:FGIsourceOpen]"
                       id="ValuesOrderedAccordingToCve-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count(tokenize(util:unsortedValues(@ism:FGIsourceOpen, $FGIsourceOpenList),' ')) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(util:unsortedValues(@ism:FGIsourceOpen, $FGIsourceOpenList),' ')) = 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'     [ISM-ID-00095][Error] If ISM_USGOV_RESOURCE and attribute FGIsourceOpen is      specified then each of its values must be ordered in accordance with CVEnumISMCATFGIOpen.xml.     '"/>
                  <xsl:text/>
      The following values are out of order [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:FGIsourceOpen, $FGIsourceOpenList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:FGIsourceOpen"/>
                  <xsl:text/>]
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M212"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M212"/>
   <xsl:template match="@*|node()" priority="-2" mode="M212">
      <xsl:apply-templates select="*" mode="M212"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00096-->


	<!--RULE ValuesOrderedAccordingToCve-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:FGIsourceProtected]"
                 priority="1000"
                 mode="M213">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:FGIsourceProtected]"
                       id="ValuesOrderedAccordingToCve-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count(tokenize(util:unsortedValues(@ism:FGIsourceProtected, $FGIsourceProtectedList),' ')) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(util:unsortedValues(@ism:FGIsourceProtected, $FGIsourceProtectedList),' ')) = 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'     [ISM-ID-00096][Error] If ISM_USGOV_RESOURCE and attribute FGIsourceProtected is specified      then each of its values must be ordered in accordance with CVEnumISMCATFGIProtected.xml.     '"/>
                  <xsl:text/>
      The following values are out of order [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:FGIsourceProtected, $FGIsourceProtectedList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:FGIsourceProtected"/>
                  <xsl:text/>]
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M213"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M213"/>
   <xsl:template match="@*|node()" priority="-2" mode="M213">
      <xsl:apply-templates select="*" mode="M213"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00097-->


	<!--RULE ISM-ID-00097-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:FGIsourceProtected]"
                 priority="1000"
                 mode="M214">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:FGIsourceProtected]"
                       id="ISM-ID-00097-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="normalize-space(string(./@ism:FGIsourceProtected))='FGI'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string(./@ism:FGIsourceProtected))='FGI'">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00097][Warning] If ISM_USGOV_RESOURCE and attribute FGIsourceProtected is 
        	specified with a value other than [FGI] then the value(s) must not be discoverable in IC shared spaces.
        	
        	Human Readable: FGI Protected should rarely if ever be seen outside of an agency's internal systems.  
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M214"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M214"/>
   <xsl:template match="@*|node()" priority="-2" mode="M214">
      <xsl:apply-templates select="*" mode="M214"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00099-->


	<!--RULE ISM-ID-00099-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:ownerProducer, ('FGI'))]"
                 priority="1000"
                 mode="M215">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:ownerProducer, ('FGI'))]"
                       id="ISM-ID-00099-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="             count(                 tokenize(normalize-space(string(@ism:ownerProducer)), ' ')             ) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( tokenize(normalize-space(string(@ism:ownerProducer)), ' ') ) = 1">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00099][Error] If ISM_USGOV_RESOURCE and attribute ownerProducer
            contains the token [FGI], then the token [FGI] must be the only value 
            in attribute ownerProducer.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M215"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M215"/>
   <xsl:template match="@*|node()" priority="-2" mode="M215">
      <xsl:apply-templates select="*" mode="M215"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00100-->


	<!--RULE ValuesOrderedAccordingToCve-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:ownerProducer]"
                 priority="1000"
                 mode="M216">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:ownerProducer]"
                       id="ValuesOrderedAccordingToCve-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count(tokenize(util:unsortedValues(@ism:ownerProducer, $ownerProducerList),' ')) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(util:unsortedValues(@ism:ownerProducer, $ownerProducerList),' ')) = 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'     [ISM-ID-00100][Error] If ISM_USGOV_RESOURCE and attribute ownerProducer is specified,      then each of its values must be ordered in accordance with CVEnumISMCATOwnerProducer.xml.     '"/>
                  <xsl:text/>
      The following values are out of order [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:ownerProducer, $ownerProducerList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:ownerProducer"/>
                  <xsl:text/>]
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M216"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M216"/>
   <xsl:template match="@*|node()" priority="-2" mode="M216">
      <xsl:apply-templates select="*" mode="M216"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00104-->


	<!--RULE ISM-ID-00104-R1-->
<xsl:template match="       *[$ISM_USGOV_RESOURCE       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)       and $bannerClassification = 'U'       and index-of($partNonICmarkings_tok, 'SBU-NF') &gt; 0       and not(util:containsAnyOfTheTokens(string-join(@ism:nonICmarkings, ' '), ('XD', 'ND')))       and not(util:containsAnyOfTheTokens(string-join(@ism:disseminationControls, ' '), ('NF')))]"
                 priority="1000"
                 mode="M217">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="       *[$ISM_USGOV_RESOURCE       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)       and $bannerClassification = 'U'       and index-of($partNonICmarkings_tok, 'SBU-NF') &gt; 0       and not(util:containsAnyOfTheTokens(string-join(@ism:nonICmarkings, ' '), ('XD', 'ND')))       and not(util:containsAnyOfTheTokens(string-join(@ism:disseminationControls, ' '), ('NF')))]"
                       id="ISM-ID-00104-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SBU-NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SBU-NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00104][Error] USA Unclassified documents having SBU-NF and not having XD, ND, or
      explicit Foriegn Disclosure and Release markings must have SBU-NF at the resource level.
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M217"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M217"/>
   <xsl:template match="@*|node()" priority="-2" mode="M217">
      <xsl:apply-templates select="*" mode="M217"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00105-->


	<!--RULE ISM-ID-00105-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and $bannerClassification = 'U' and index-of($partNonICmarkings_tok, 'SBU') &gt; 0 and not(util:containsAnyOfTheTokens(string-join($partNonICmarkings, ' '), ('SBU-NF', 'XD', 'ND')))]"
                 priority="1000"
                 mode="M218">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and $bannerClassification = 'U' and index-of($partNonICmarkings_tok, 'SBU') &gt; 0 and not(util:containsAnyOfTheTokens(string-join($partNonICmarkings, ' '), ('SBU-NF', 'XD', 'ND')))]"
                       id="ISM-ID-00105-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SBU'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SBU'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00105][Error] USA Unclassified documents having SBU and not having SBU-NF, XD, or ND
      must have SBU at the resource level. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M218"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M218"/>
   <xsl:template match="@*|node()" priority="-2" mode="M218">
      <xsl:apply-templates select="*" mode="M218"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00107-->


	<!--RULE ISM-ID-00107-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('IMC'))]"
                 priority="1000"
                 mode="M219">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('IMC'))]"
                       id="ISM-ID-00107-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:classification=('TS', 'S')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:classification=('TS', 'S')">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00107][Error] If ISM_USGOV_RESOURCE and attribute 
        	disseminationControls contains the name token [IMC] then attribute 
        	classification must have a value of [TS] or [S].
        	
        	Human Readable:  IMCON data is SECRET (S), but may appear with 
        	S or TOP SECRET data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M219"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M219"/>
   <xsl:template match="@*|node()" priority="-2" mode="M219">
      <xsl:apply-templates select="*" mode="M219"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00108-->


	<!--RULE NonCompilationDocumentRollup-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('TS'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"
                 priority="1000"
                 mode="M220">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('TS'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"
                       id="NonCompilationDocumentRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="         some $ele in $partTags satisfies           util:containsAnyOfTheTokens($ele/@ism:classification, ('TS'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:classification, ('TS'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00108][Error] USA TS documents not using compilation must have TS data.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M220"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M220"/>
   <xsl:template match="@*|node()" priority="-2" mode="M220">
      <xsl:apply-templates select="*" mode="M220"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00109-->


	<!--RULE NonCompilationDocumentRollup-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('S'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"
                 priority="1000"
                 mode="M221">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('S'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"
                       id="NonCompilationDocumentRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="         some $ele in $partTags satisfies           util:containsAnyOfTheTokens($ele/@ism:classification, ('S'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:classification, ('S'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00109][Error] USA S documents not using compilation must have S data.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M221"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M221"/>
   <xsl:template match="@*|node()" priority="-2" mode="M221">
      <xsl:apply-templates select="*" mode="M221"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00110-->


	<!--RULE NonCompilationDocumentRollup-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('C'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"
                 priority="1000"
                 mode="M222">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:classification, ('C'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"
                       id="NonCompilationDocumentRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="         some $ele in $partTags satisfies           util:containsAnyOfTheTokens($ele/@ism:classification, ('C'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:classification, ('C'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00110][Error] USA C documents not using compilation must have C data.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M222"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M222"/>
   <xsl:template match="@*|node()" priority="-2" mode="M222">
      <xsl:apply-templates select="*" mode="M222"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00121-->


	<!--RULE ValuesOrderedAccordingToCveWhenContributesToRollup-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:SARIdentifier]"
                 priority="1000"
                 mode="M223">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:SARIdentifier]"
                       id="ValuesOrderedAccordingToCveWhenContributesToRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="if (util:contributesToRollup(.)) then count(tokenize(util:unsortedValues(@ism:SARIdentifier, $SARIdentifierList),' '))=0 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (util:contributesToRollup(.)) then count(tokenize(util:unsortedValues(@ism:SARIdentifier, $SARIdentifierList),' '))=0 else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00121][Error] If ISM_USGOV_RESOURCE and attribute SARIdentifier is specified and contributes to rollup, its values must be ordered in accordance with CVEnumISMSAR.xml.'"/>
                  <xsl:text/>
      The following values [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:SARIdentifier, $SARIdentifierList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:SARIdentifier"/>
                  <xsl:text/>] that contribute to rollup are out of order with respect to its CVE.
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="if (not(util:contributesToRollup(.))) then count(tokenize(util:nonalphabeticValues(tokenize(normalize-space(string(@ism:SARIdentifier)), ' ')),' '))=0 else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (not(util:contributesToRollup(.))) then count(tokenize(util:nonalphabeticValues(tokenize(normalize-space(string(@ism:SARIdentifier)), ' ')),' '))=0 else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00121][Error] If ISM_USGOV_RESOURCE and attribute SARIdentifier is specified but does not contribute to rollup, its values must be ordered alphabetically.'"/>
                  <xsl:text/>
      The following values [<xsl:text/>
                  <xsl:value-of select="util:nonalphabeticValues(tokenize(normalize-space(string(@ism:SARIdentifier)), ' '))"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:SARIdentifier"/>
                  <xsl:text/>] that does not contribute to rollup are not in the expected alphabetical order.
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M223"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M223"/>
   <xsl:template match="@*|node()" priority="-2" mode="M223">
      <xsl:apply-templates select="*" mode="M223"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00124-->


	<!--RULE ISM-ID-00124-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('RELIDO'))]"
                 priority="1000"
                 mode="M224">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('RELIDO'))]"
                       id="ISM-ID-00124-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:ownerProducer, ('USA'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:ownerProducer, ('USA'))">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00124][Warning] If ISM_USGOV_RESOURCE and
          1. Attribute ownerProducer does not contain [USA].
          AND
          2. Attribute disseminationControls contains [RELIDO]
          
          Human Readable: RELIDO is not authorized for non-US portions.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M224"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M224"/>
   <xsl:template match="@*|node()" priority="-2" mode="M224">
      <xsl:apply-templates select="*" mode="M224"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00127-->


	<!--RULE DataHasCorrespondingNotice-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))]"
                 priority="1000"
                 mode="M225">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))]"
                       id="DataHasCorrespondingNotice-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('RD')) and not ($elem/@ism:externalNotice=true()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('RD')) and not ($elem/@ism:externalNotice=true()))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00127'"/>
                  <xsl:text/>][Error] If ISM_USGOV_RESOURCE, any
			element meeting ISM_CONTRIBUTES in the document has the attribute <xsl:text/>
                  <xsl:value-of select="'atomicEnergyMarkings'"/>
                  <xsl:text/> containing [<xsl:text/>
                  <xsl:value-of select="'RD'"/>
                  <xsl:text/>], then some
			element meeting ISM_CONTRIBUTES in the document MUST have attribute noticeType
			containing [<xsl:text/>
                  <xsl:value-of select="'RD'"/>
                  <xsl:text/>].</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M225"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M225"/>
   <xsl:template match="@*|node()" priority="-2" mode="M225">
      <xsl:apply-templates select="*" mode="M225"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00128-->


	<!--RULE DataHasCorrespondingNoticeWithException-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and    util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:atomicEnergyMarkings, ('FRD')) and not(util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:atomicEnergyMarkings, ('RD')))]"
                 priority="1000"
                 mode="M226">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and    util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:atomicEnergyMarkings, ('FRD')) and not(util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:atomicEnergyMarkings, ('RD')))]"
                       id="DataHasCorrespondingNoticeWithException-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="     some $elem in $partTags      satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('FRD')) and not($elem/@ism:externalNotice = true()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('FRD')) and not($elem/@ism:externalNotice = true()))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00128'"/>
                  <xsl:text/>][Error] If ISM_USGOV_RESOURCE, any
			element meeting ISM_CONTRIBUTES in the document has the attribute <xsl:text/>
                  <xsl:value-of select="'atomicEnergyMarkings'"/>
                  <xsl:text/> containing [<xsl:text/>
                  <xsl:value-of select="'FRD'"/>
                  <xsl:text/>], then some
			element meeting ISM_CONTRIBUTES in the document MUST have attribute noticeType
			containing [<xsl:text/>
                  <xsl:value-of select="'FRD'"/>
                  <xsl:text/>].</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M226"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M226"/>
   <xsl:template match="@*|node()" priority="-2" mode="M226">
      <xsl:apply-templates select="*" mode="M226"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00129-->


	<!--RULE DataHasCorrespondingNotice-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and util:containsAnyOfTheTokens(@ism:disseminationControls, ('IMC'))]"
                 priority="1000"
                 mode="M227">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and util:containsAnyOfTheTokens(@ism:disseminationControls, ('IMC'))]"
                       id="DataHasCorrespondingNotice-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('IMC')) and not ($elem/@ism:externalNotice=true()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('IMC')) and not ($elem/@ism:externalNotice=true()))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00129'"/>
                  <xsl:text/>][Error] If ISM_USGOV_RESOURCE, any
			element meeting ISM_CONTRIBUTES in the document has the attribute <xsl:text/>
                  <xsl:value-of select="'disseminationControls'"/>
                  <xsl:text/> containing [<xsl:text/>
                  <xsl:value-of select="'IMC'"/>
                  <xsl:text/>], then some
			element meeting ISM_CONTRIBUTES in the document MUST have attribute noticeType
			containing [<xsl:text/>
                  <xsl:value-of select="'IMC'"/>
                  <xsl:text/>].</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M227"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M227"/>
   <xsl:template match="@*|node()" priority="-2" mode="M227">
      <xsl:apply-templates select="*" mode="M227"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00130-->


	<!--RULE DataHasCorrespondingNotice-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and util:containsAnyOfTheTokens(@ism:disseminationControls, ('FISA'))]"
                 priority="1000"
                 mode="M228">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and util:containsAnyOfTheTokens(@ism:disseminationControls, ('FISA'))]"
                       id="DataHasCorrespondingNotice-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('FISA')) and not ($elem/@ism:externalNotice=true()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('FISA')) and not ($elem/@ism:externalNotice=true()))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00130'"/>
                  <xsl:text/>][Error] If ISM_USGOV_RESOURCE, any
			element meeting ISM_CONTRIBUTES in the document has the attribute <xsl:text/>
                  <xsl:value-of select="'disseminationControls'"/>
                  <xsl:text/> containing [<xsl:text/>
                  <xsl:value-of select="'FISA'"/>
                  <xsl:text/>], then some
			element meeting ISM_CONTRIBUTES in the document MUST have attribute noticeType
			containing [<xsl:text/>
                  <xsl:value-of select="'FISA'"/>
                  <xsl:text/>].</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M228"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M228"/>
   <xsl:template match="@*|node()" priority="-2" mode="M228">
      <xsl:apply-templates select="*" mode="M228"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00132-->


	<!--RULE ISM-ID-00132-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)         and util:containsAnyOfTheTokens(@ism:disseminationControls, ('RELIDO'))]"
                 priority="1000"
                 mode="M229">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)         and util:containsAnyOfTheTokens(@ism:disseminationControls, ('RELIDO'))]"
                       id="ISM-ID-00132-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $ele in $partTags satisfies             if  ($ele/@ism:classification[normalize-space()='U']                  and not(util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('REL','NF','DISPLAYONLY')))                 and not(util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('SBU-NF', 'LES-NF'))))             then true()             else util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('RELIDO'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $ele in $partTags satisfies if ($ele/@ism:classification[normalize-space()='U'] and not(util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('REL','NF','DISPLAYONLY'))) and not(util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('SBU-NF', 'LES-NF')))) then true() else util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('RELIDO'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [ISM-ID-00132][Error] USA documents having RELIDO at the resource level
            must have every classified portion having RELIDO and on any U portions that have
            explicit Release specified must have RELIDO. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M229"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M229"/>
   <xsl:template match="@*|node()" priority="-2" mode="M229">
      <xsl:apply-templates select="*" mode="M229"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00133-->


	<!--RULE ISM-ID-00133-R1-->
<xsl:template match="*[$ISM_NSI_EO_APPLIES         and util:containsAnyOfTheTokens(@ism:declassException, ('25X1-EO-12951', '50X1-HUM', '50X2-WMD', 'NATO', 'AEA', 'NATO-AEA'))]"
                 priority="1000"
                 mode="M230">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_NSI_EO_APPLIES         and util:containsAnyOfTheTokens(@ism:declassException, ('25X1-EO-12951', '50X1-HUM', '50X2-WMD', 'NATO', 'AEA', 'NATO-AEA'))]"
                       id="ISM-ID-00133-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(@ism:declassDate or @ism:declassEvent)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@ism:declassDate or @ism:declassEvent)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00133][Error] If ISM_NSI_EO_APPLIES and attribute 
			declassException is specified and contains the tokens [25X1-EO-12951],
			[50X1-HUM], [50X2-WMD], [NATO], [AEA] or [NATO-AEA]then attribute declassDate 
			or declassEvent must NOT be specified.
			
			Human Readable: Documents under E.O. 13526 must not specify declassDate
			or declassEvent if a declassException of 25X1-EO-12951, 50X1-HUM, 
			50X2-WMD, NATO, AEA or NATO-AEA  is specified.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M230"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M230"/>
   <xsl:template match="@*|node()" priority="-2" mode="M230">
      <xsl:apply-templates select="*" mode="M230"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00134-->


	<!--RULE DataHasCorrespondingNotice-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('DS'))]"
                 priority="1000"
                 mode="M231">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('DS'))]"
                       id="DataHasCorrespondingNotice-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('DS')) and not ($elem/@ism:externalNotice=true()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('DS')) and not ($elem/@ism:externalNotice=true()))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00134'"/>
                  <xsl:text/>][Error] If ISM_USGOV_RESOURCE, any
			element meeting ISM_CONTRIBUTES in the document has the attribute <xsl:text/>
                  <xsl:value-of select="'nonICmarkings'"/>
                  <xsl:text/> containing [<xsl:text/>
                  <xsl:value-of select="'DS'"/>
                  <xsl:text/>], then some
			element meeting ISM_CONTRIBUTES in the document MUST have attribute noticeType
			containing [<xsl:text/>
                  <xsl:value-of select="'DS'"/>
                  <xsl:text/>].</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M231"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M231"/>
   <xsl:template match="@*|node()" priority="-2" mode="M231">
      <xsl:apply-templates select="*" mode="M231"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00135-->


	<!--RULE NoticeHasCorrespondingData-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and not (@ism:externalNotice=true()) and util:containsAnyOfTheTokens(@ism:noticeType, ('RD'))]"
                 priority="1000"
                 mode="M232">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and not (@ism:externalNotice=true()) and util:containsAnyOfTheTokens(@ism:noticeType, ('RD'))]"
                       id="NoticeHasCorrespondingData-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="index-of($partAtomicEnergyMarkings_tok, 'RD')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partAtomicEnergyMarkings_tok, 'RD')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00135'"/>
                  <xsl:text/>][Error] If ISM_USGOV_RESOURCE and any element meeting
			ISM_CONTRIBUTES in the document has the attribute noticeType containing [<xsl:text/>
                  <xsl:value-of select="'RD'"/>
                  <xsl:text/>], then some element meeting ISM_CONTRIBUTES in the document
			MUST have attribute <xsl:text/>
                  <xsl:value-of select="'atomicEnergyMarkings'"/>
                  <xsl:text/> containing [<xsl:text/>
                  <xsl:value-of select="'RD'"/>
                  <xsl:text/>]. Human Readable: USA documents containing an <xsl:text/>
                  <xsl:value-of select="'RD'"/>
                  <xsl:text/> notice must also have <xsl:text/>
                  <xsl:value-of select="'RD'"/>
                  <xsl:text/> data.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M232"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M232"/>
   <xsl:template match="@*|node()" priority="-2" mode="M232">
      <xsl:apply-templates select="*" mode="M232"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00136-->


	<!--RULE NoticeHasCorrespondingData-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and not (@ism:externalNotice=true()) and util:containsAnyOfTheTokens(@ism:noticeType, ('FRD'))]"
                 priority="1000"
                 mode="M233">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and not (@ism:externalNotice=true()) and util:containsAnyOfTheTokens(@ism:noticeType, ('FRD'))]"
                       id="NoticeHasCorrespondingData-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="index-of($partAtomicEnergyMarkings_tok, 'FRD')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partAtomicEnergyMarkings_tok, 'FRD')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00136'"/>
                  <xsl:text/>][Error] If ISM_USGOV_RESOURCE and any element meeting
			ISM_CONTRIBUTES in the document has the attribute noticeType containing [<xsl:text/>
                  <xsl:value-of select="'FRD'"/>
                  <xsl:text/>], then some element meeting ISM_CONTRIBUTES in the document
			MUST have attribute <xsl:text/>
                  <xsl:value-of select="'atomicEnergyMarkings'"/>
                  <xsl:text/> containing [<xsl:text/>
                  <xsl:value-of select="'FRD'"/>
                  <xsl:text/>]. Human Readable: USA documents containing an <xsl:text/>
                  <xsl:value-of select="'FRD'"/>
                  <xsl:text/> notice must also have <xsl:text/>
                  <xsl:value-of select="'FRD'"/>
                  <xsl:text/> data.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M233"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M233"/>
   <xsl:template match="@*|node()" priority="-2" mode="M233">
      <xsl:apply-templates select="*" mode="M233"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00137-->


	<!--RULE NoticeHasCorrespondingData-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and not (@ism:externalNotice=true()) and util:containsAnyOfTheTokens(@ism:noticeType, ('IMC'))]"
                 priority="1000"
                 mode="M234">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and not (@ism:externalNotice=true()) and util:containsAnyOfTheTokens(@ism:noticeType, ('IMC'))]"
                       id="NoticeHasCorrespondingData-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="index-of($partDisseminationControls_tok, 'IMC')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partDisseminationControls_tok, 'IMC')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00137'"/>
                  <xsl:text/>][Error] If ISM_USGOV_RESOURCE and any element meeting
			ISM_CONTRIBUTES in the document has the attribute noticeType containing [<xsl:text/>
                  <xsl:value-of select="'IMC'"/>
                  <xsl:text/>], then some element meeting ISM_CONTRIBUTES in the document
			MUST have attribute <xsl:text/>
                  <xsl:value-of select="'disseminationControls'"/>
                  <xsl:text/> containing [<xsl:text/>
                  <xsl:value-of select="'IMC'"/>
                  <xsl:text/>]. Human Readable: USA documents containing an <xsl:text/>
                  <xsl:value-of select="'IMC'"/>
                  <xsl:text/> notice must also have <xsl:text/>
                  <xsl:value-of select="'IMC'"/>
                  <xsl:text/> data.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M234"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M234"/>
   <xsl:template match="@*|node()" priority="-2" mode="M234">
      <xsl:apply-templates select="*" mode="M234"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00138-->


	<!--RULE NoticeHasCorrespondingDataUnclassDoc-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:classification, ('U'))   and not (@ism:externalNotice=true()) and util:containsAnyOfTheTokens(@ism:noticeType, ('DS'))]"
                 priority="1000"
                 mode="M235">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:classification, ('U'))   and not (@ism:externalNotice=true()) and util:containsAnyOfTheTokens(@ism:noticeType, ('DS'))]"
                       id="NoticeHasCorrespondingDataUnclassDoc-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="index-of($partNonICmarkings_tok, 'DS')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partNonICmarkings_tok, 'DS')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00138'"/>
                  <xsl:text/>][Error] If ISM_USGOV_RESOURCE and any element meeting
			ISM_CONTRIBUTES in the document has the attribute noticeType containing [<xsl:text/>
                  <xsl:value-of select="'DS'"/>
                  <xsl:text/>], then some element meeting ISM_CONTRIBUTES in the document
			MUST have attribute <xsl:text/>
                  <xsl:value-of select="'nonICmarkings'"/>
                  <xsl:text/> containing [<xsl:text/>
                  <xsl:value-of select="'DS'"/>
                  <xsl:text/>]. Human Readable: USA documents containing an <xsl:text/>
                  <xsl:value-of select="'DS'"/>
                  <xsl:text/> notice must also have <xsl:text/>
                  <xsl:value-of select="'DS'"/>
                  <xsl:text/> data.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M235"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M235"/>
   <xsl:template match="@*|node()" priority="-2" mode="M235">
      <xsl:apply-templates select="*" mode="M235"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00139-->


	<!--RULE NoticeHasCorrespondingData-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and not (@ism:externalNotice=true()) and util:containsAnyOfTheTokens(@ism:noticeType, ('FISA'))]"
                 priority="1000"
                 mode="M236">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and not (@ism:externalNotice=true()) and util:containsAnyOfTheTokens(@ism:noticeType, ('FISA'))]"
                       id="NoticeHasCorrespondingData-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="index-of($partDisseminationControls_tok, 'FISA')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partDisseminationControls_tok, 'FISA')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00139'"/>
                  <xsl:text/>][Error] If ISM_USGOV_RESOURCE and any element meeting
			ISM_CONTRIBUTES in the document has the attribute noticeType containing [<xsl:text/>
                  <xsl:value-of select="'FISA'"/>
                  <xsl:text/>], then some element meeting ISM_CONTRIBUTES in the document
			MUST have attribute <xsl:text/>
                  <xsl:value-of select="'disseminationControls'"/>
                  <xsl:text/> containing [<xsl:text/>
                  <xsl:value-of select="'FISA'"/>
                  <xsl:text/>]. Human Readable: USA documents containing an <xsl:text/>
                  <xsl:value-of select="'FISA'"/>
                  <xsl:text/> notice must also have <xsl:text/>
                  <xsl:value-of select="'FISA'"/>
                  <xsl:text/> data.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M236"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M236"/>
   <xsl:template match="@*|node()" priority="-2" mode="M236">
      <xsl:apply-templates select="*" mode="M236"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00141-->


	<!--RULE ISM-ID-00141-R1-->
<xsl:template match="             *[$ISM_NSI_EO_APPLIES and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and             not(util:containsAnyOfTheTokens(@ism:declassException, ('25X1-EO-12951', '50X1-HUM', '50X2-WMD', 'AEA', 'NATO', 'NATO-AEA')))]"
                 priority="1000"
                 mode="M237">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="             *[$ISM_NSI_EO_APPLIES and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and             not(util:containsAnyOfTheTokens(@ism:declassException, ('25X1-EO-12951', '50X1-HUM', '50X2-WMD', 'AEA', 'NATO', 'NATO-AEA')))]"
                       id="ISM-ID-00141-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:declassDate or @ism:declassEvent"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:declassDate or @ism:declassEvent">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [ISM-ID-00141][Error]
            Documents under E.O. 13526 require declassDate or declassEvent unless 25X1-EO-12951,
            50X1-HUM, 50X2-WMD, AEA, NATO, or NATO-AEA is specified.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M237"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M237"/>
   <xsl:template match="@*|node()" priority="-2" mode="M237">
      <xsl:apply-templates select="*" mode="M237"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00142-->


	<!--RULE ISM-ID-00142-R1-->
<xsl:template match="*[$ISM_NSI_EO_APPLIES and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M238">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_NSI_EO_APPLIES and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                       id="ISM-ID-00142-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:classifiedBy or @ism:derivativelyClassifiedBy"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:classifiedBy or @ism:derivativelyClassifiedBy">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ISM-ID-00142][Error] If the Classified National Security Information Executive Order
            applies to the document, then a classification authority must be specified.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M238"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M238"/>
   <xsl:template match="@*|node()" priority="-2" mode="M238">
      <xsl:apply-templates select="*" mode="M238"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00143-->


	<!--RULE ISM-ID-00143-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:derivativelyClassifiedBy]"
                 priority="1000"
                 mode="M239">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:derivativelyClassifiedBy]"
                       id="ISM-ID-00143-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:derivedFrom"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:derivedFrom">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00143][Error] If ISM_USGOV_RESOURCE and attribute 
        	derivativelyClassifiedBy is specified, then attribute derivedFrom must
        	be specified. 
        	
        	Human Readable: Derivatively Classified data including DOE data requires
        	a derived from value to be identified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M239"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M239"/>
   <xsl:template match="@*|node()" priority="-2" mode="M239">
      <xsl:apply-templates select="*" mode="M239"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00145-->


	<!--RULE ISM-ID-00145-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and index-of($partNonICmarkings_tok, 'LES') &gt; 0                         and not(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0)]"
                 priority="1000"
                 mode="M240">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and index-of($partNonICmarkings_tok, 'LES') &gt; 0                         and not(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0)]"
                       id="ISM-ID-00145-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00145][Error] USA documents having LES and not having LES-NF must have LES at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M240"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M240"/>
   <xsl:template match="@*|node()" priority="-2" mode="M240">
      <xsl:apply-templates select="*" mode="M240"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00146-->


	<!--RULE ISM-ID-00146-R1-->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M241">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                       id="ISM-ID-00146-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="             if(not($ISM_USGOV_RESOURCE)) then true() else                 if(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0 and not($bannerClassification='U'))                  then (index-of($bannerDisseminationControls_tok, 'NF') &gt; 0)                 else true()             "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_USGOV_RESOURCE)) then true() else if(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0 and not($bannerClassification='U')) then (index-of($bannerDisseminationControls_tok, 'NF') &gt; 0) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00146][Error] Classified USA documents having LES-NF Data must have NF at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M241"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M241"/>
   <xsl:template match="@*|node()" priority="-2" mode="M241">
      <xsl:apply-templates select="*" mode="M241"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00147-->


	<!--RULE ISM-ID-00147-R1-->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M242">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                       id="ISM-ID-00147-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="if(not($ISM_USGOV_RESOURCE)) then true() else if(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0 and not($bannerClassification='U')) then (index-of($bannerNonICmarkings_tok, 'LES') &gt; 0) else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(not($ISM_USGOV_RESOURCE)) then true() else if(index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0 and not($bannerClassification='U')) then (index-of($bannerNonICmarkings_tok, 'LES') &gt; 0) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00147][Error] Classified USA documents having LES-NF Data must have LES at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M242"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M242"/>
   <xsl:template match="@*|node()" priority="-2" mode="M242">
      <xsl:apply-templates select="*" mode="M242"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00148-->


	<!--RULE MutuallyExclusiveAttributeValues-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE          and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES', 'LES-NF'))]"
                 priority="1000"
                 mode="M243">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE          and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES', 'LES-NF'))]"
                       id="MutuallyExclusiveAttributeValues-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( for $token in tokenize(normalize-space(string(@ism:nonICmarkings)),' ') return  if($token = ('LES', 'LES-NF')) then 1 else null ) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( for $token in tokenize(normalize-space(string(@ism:nonICmarkings)),' ') return if($token = ('LES', 'LES-NF')) then 1 else null ) = 1">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00148][Error] If ISM_USGOV_RESOURCE, then Name tokens    [LES] and [LES-NF] are mutually exclusive for attribute nonICmarkings.      Human Readable: USA documents must not specify both LES and LES-NF    on a single element.   '"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M243"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M243"/>
   <xsl:template match="@*|node()" priority="-2" mode="M243">
      <xsl:apply-templates select="*" mode="M243"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00149-->


	<!--RULE ISM-ID-00149-R1-->
<xsl:template match="       *[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)       and $bannerClassification = 'U' and index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0       and not(util:containsAnyOfTheTokens(string-join(@ism:disseminationControls, ' '), ('NF')))]"
                 priority="1000"
                 mode="M244">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="       *[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)       and $bannerClassification = 'U' and index-of($partNonICmarkings_tok, 'LES-NF') &gt; 0       and not(util:containsAnyOfTheTokens(string-join(@ism:disseminationControls, ' '), ('NF')))]"
                       id="ISM-ID-00149-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES-NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES-NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00149][Error] Unclassified USA documents having LES-NF and not having NF must 
      have LES-NF at the resource level. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M244"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M244"/>
   <xsl:template match="@*|node()" priority="-2" mode="M244">
      <xsl:apply-templates select="*" mode="M244"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00150-->


	<!--RULE ISM-ID-00150-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                       and not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))                       and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES'))]"
                 priority="1000"
                 mode="M245">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                       and not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))                       and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES'))]"
                       id="ISM-ID-00150-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="some $elem in $partTags satisfies          ($elem[@ism:noticeType]          and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('LES'))          and not ($elem/@ism:externalNotice=true()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('LES')) and not ($elem/@ism:externalNotice=true()))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00150][Error] If ISM_USGOV_RESOURCE and:
      1. Any element, other than ISM_RESOURCE_ELEMENT, meeting ISM_CONTRIBUTES in the document has the attribute nonICmarkings containing [LES]
      AND
      2. No element meeting ISM_CONTRIBUTES in the document has the attribute noticeType containing [LES]
      
      Human Readable: USA documents containing LES data must also have an LES notice.
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M245"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M245"/>
   <xsl:template match="@*|node()" priority="-2" mode="M245">
      <xsl:apply-templates select="*" mode="M245"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00151-->


	<!--RULE NoticeHasCorrespondingData-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and not (@ism:externalNotice=true()) and util:containsAnyOfTheTokens(@ism:noticeType, ('LES'))]"
                 priority="1000"
                 mode="M246">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and not (@ism:externalNotice=true()) and util:containsAnyOfTheTokens(@ism:noticeType, ('LES'))]"
                       id="NoticeHasCorrespondingData-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="index-of($partNonICmarkings_tok, 'LES')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partNonICmarkings_tok, 'LES')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00151'"/>
                  <xsl:text/>][Error] If ISM_USGOV_RESOURCE and any element meeting
			ISM_CONTRIBUTES in the document has the attribute noticeType containing [<xsl:text/>
                  <xsl:value-of select="'LES'"/>
                  <xsl:text/>], then some element meeting ISM_CONTRIBUTES in the document
			MUST have attribute <xsl:text/>
                  <xsl:value-of select="'nonICmarkings'"/>
                  <xsl:text/> containing [<xsl:text/>
                  <xsl:value-of select="'LES'"/>
                  <xsl:text/>]. Human Readable: USA documents containing an <xsl:text/>
                  <xsl:value-of select="'LES'"/>
                  <xsl:text/> notice must also have <xsl:text/>
                  <xsl:value-of select="'LES'"/>
                  <xsl:text/> data.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M246"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M246"/>
   <xsl:template match="@*|node()" priority="-2" mode="M246">
      <xsl:apply-templates select="*" mode="M246"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00152-->


	<!--RULE DataHasCorrespondingNotice-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES-NF'))]"
                 priority="1000"
                 mode="M247">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES-NF'))]"
                       id="DataHasCorrespondingNotice-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('LES-NF')) and not ($elem/@ism:externalNotice=true()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('LES-NF')) and not ($elem/@ism:externalNotice=true()))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00152'"/>
                  <xsl:text/>][Error] If ISM_USGOV_RESOURCE, any
			element meeting ISM_CONTRIBUTES in the document has the attribute <xsl:text/>
                  <xsl:value-of select="'nonICmarkings'"/>
                  <xsl:text/> containing [<xsl:text/>
                  <xsl:value-of select="'LES-NF'"/>
                  <xsl:text/>], then some
			element meeting ISM_CONTRIBUTES in the document MUST have attribute noticeType
			containing [<xsl:text/>
                  <xsl:value-of select="'LES-NF'"/>
                  <xsl:text/>].</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M247"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M247"/>
   <xsl:template match="@*|node()" priority="-2" mode="M247">
      <xsl:apply-templates select="*" mode="M247"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00153-->


	<!--RULE NoticeHasCorrespondingData-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and not (@ism:externalNotice=true()) and util:containsAnyOfTheTokens(@ism:noticeType, ('LES-NF'))]"
                 priority="1000"
                 mode="M248">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and not (@ism:externalNotice=true()) and util:containsAnyOfTheTokens(@ism:noticeType, ('LES-NF'))]"
                       id="NoticeHasCorrespondingData-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="index-of($partNonICmarkings_tok, 'LES-NF')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partNonICmarkings_tok, 'LES-NF')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00153'"/>
                  <xsl:text/>][Error] If ISM_USGOV_RESOURCE and any element meeting
			ISM_CONTRIBUTES in the document has the attribute noticeType containing [<xsl:text/>
                  <xsl:value-of select="'LES-NF'"/>
                  <xsl:text/>], then some element meeting ISM_CONTRIBUTES in the document
			MUST have attribute <xsl:text/>
                  <xsl:value-of select="'nonICmarkings'"/>
                  <xsl:text/> containing [<xsl:text/>
                  <xsl:value-of select="'LES-NF'"/>
                  <xsl:text/>]. Human Readable: USA documents containing an <xsl:text/>
                  <xsl:value-of select="'LES-NF'"/>
                  <xsl:text/> notice must also have <xsl:text/>
                  <xsl:value-of select="'LES-NF'"/>
                  <xsl:text/> data.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M248"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M248"/>
   <xsl:template match="@*|node()" priority="-2" mode="M248">
      <xsl:apply-templates select="*" mode="M248"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00154-->


	<!--RULE NonCompilationDocumentRollup-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"
                 priority="1000"
                 mode="M249">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))                       and string-length(normalize-space(@ism:compilationReason)) = 0]"
                       id="NonCompilationDocumentRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="         some $ele in $partTags satisfies           util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('FOUO'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('FOUO'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00154][Error] USA FOUO documents not using compilation must have FOUO data.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M249"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M249"/>
   <xsl:template match="@*|node()" priority="-2" mode="M249">
      <xsl:apply-templates select="*" mode="M249"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00159-->


	<!--RULE ISM-ID-00159-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                          and not($ISM_RESOURCE_ELEMENT/@ism:classification = 'U')]"
                 priority="1000"
                 mode="M250">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                          and not($ISM_RESOURCE_ELEMENT/@ism:classification = 'U')]"
                       id="ISM-ID-00159-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(util:containsAnyOfTheTokens(@ism:noticeType, ('DoD-Dist-A')))                 or (@ism:externalNotice=true())"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyOfTheTokens(@ism:noticeType, ('DoD-Dist-A'))) or (@ism:externalNotice=true())">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
            [ISM-ID-00159][Error] If ISM_USGOV_RESOURCE and:
        1. attribute classification of ISM_RESOURCE_ELEMENT is not [U]
        AND
        2. The attribute notice does contains [DoD-Dist-A]
        or has attribute externalNotice with a value of [true].
        Human Readable: Distribution statement A (Public Release) is forbidden on classified documents.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M250"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M250"/>
   <xsl:template match="@*|node()" priority="-2" mode="M250">
      <xsl:apply-templates select="*" mode="M250"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00164-->


	<!--RULE ISM-ID-00164-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                       and util:containsAnyOfTheTokens(@ism:disseminationControls, ('RS'))]"
                 priority="1000"
                 mode="M251">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                       and util:containsAnyOfTheTokens(@ism:disseminationControls, ('RS'))]"
                       id="ISM-ID-00164-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:classification=('TS', 'S')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:classification=('TS', 'S')">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00164][Error] If ISM_USGOV_RESOURCE and attribute 
            disseminationControls contains the name token [RS],
            then attribute classification must have a value of [TS] or [S].
            
            Human Readable: USA documents with RISK SENSITIVE dissemination must
            be classified SECRET or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M251"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M251"/>
   <xsl:template match="@*|node()" priority="-2" mode="M251">
      <xsl:apply-templates select="*" mode="M251"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00165-->


	<!--RULE AttributeContributesToRollup-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('RS')))]"
                 priority="1000"
                 mode="M252">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:disseminationControls, ('RS')))]"
                       id="AttributeContributesToRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('RS'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('RS'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00165][Error] USA documents having RISK SENSITIVE (RS) data must have RS at the resource level.'"/>
                  <xsl:text/> 
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M252"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M252"/>
   <xsl:template match="@*|node()" priority="-2" mode="M252">
      <xsl:apply-templates select="*" mode="M252"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00166-->


	<!--RULE AttributeValueDeprecatedWarning-R1-->
<xsl:template match="*[@ism:classification]" priority="1000" mode="M253">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:classification]"
                       id="AttributeValueDeprecatedWarning-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:classification), document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:classification), document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00166'"/>
                  <xsl:text/>][Warning] For attribute <xsl:text/>
                  <xsl:value-of select="'classification'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated(string(@ism:classification), document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE,false())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M253"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M253"/>
   <xsl:template match="@*|node()" priority="-2" mode="M253">
      <xsl:apply-templates select="*" mode="M253"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00167-->


	<!--RULE ValuesOrderedAccordingToCve-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:displayOnlyTo]"
                 priority="1000"
                 mode="M254">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:displayOnlyTo]"
                       id="ValuesOrderedAccordingToCve-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count(tokenize(util:unsortedValues(@ism:displayOnlyTo, $displayOnlyToList),' ')) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(util:unsortedValues(@ism:displayOnlyTo, $displayOnlyToList),' ')) = 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'     [ISM-ID-00167][Error] If ISM_USGOV_RESOURCE and attribute displayOnlyTo is specified,      then each of its values must be ordered in accordance with CVEnumISMCATRelTo.xml.     '"/>
                  <xsl:text/>
      The following values are out of order [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:displayOnlyTo, $displayOnlyToList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:displayOnlyTo"/>
                  <xsl:text/>]
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M254"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M254"/>
   <xsl:template match="@*|node()" priority="-2" mode="M254">
      <xsl:apply-templates select="*" mode="M254"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00168-->


	<!--RULE ISM-ID-00168-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                       and not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY')))]"
                 priority="1000"
                 mode="M255">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                       and not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY')))]"
                       id="ISM-ID-00168-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(@ism:displayOnlyTo)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@ism:displayOnlyTo)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00168][Error] If ISM_USGOV_RESOURCE and attribute 
            disseminationControls is not specified or is specified and does not contain the name token 
            [DISPLAYONLY], then attribute displayOnlyTo must not be specified.
            
            Human Readable: If a portion in a USA document is not marked for DISPLAY ONLY dissemination, 
            it must not list countries to which it may be disclosed.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M255"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M255"/>
   <xsl:template match="@*|node()" priority="-2" mode="M255">
      <xsl:apply-templates select="*" mode="M255"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00169-->


	<!--RULE MutuallyExclusiveAttributeValues-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                                    and util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY', 'RELIDO', 'NF'))]"
                 priority="1000"
                 mode="M256">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                                    and util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY', 'RELIDO', 'NF'))]"
                       id="MutuallyExclusiveAttributeValues-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( for $token in tokenize(normalize-space(string(@ism:disseminationControls)),' ') return  if($token = ('DISPLAYONLY', 'RELIDO', 'NF')) then 1 else null ) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( for $token in tokenize(normalize-space(string(@ism:disseminationControls)),' ') return if($token = ('DISPLAYONLY', 'RELIDO', 'NF')) then 1 else null ) = 1">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'    [ISM-ID-00169][Error] If ISM_USGOV_RESOURCE, then for attribute disseminationControls     the name tokens [DISPLAYONLY], [RELIDO] and [NF] are mutually exclusive.        Human Readable: In a USA document, DISPLAY ONLY, RELIDO and NO FOREIGN dissemination are     mutually exclusive for a single element.   '"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M256"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M256"/>
   <xsl:template match="@*|node()" priority="-2" mode="M256">
      <xsl:apply-templates select="*" mode="M256"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00170-->


	<!--RULE AttributeValueDeprecatedError-R1-->
<xsl:template match="*[@ism:classification]" priority="1000" mode="M257">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:classification]"
                       id="AttributeValueDeprecatedError-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:classification), document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:classification), document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00170'"/>
                  <xsl:text/>][Error] For attribute <xsl:text/>
                  <xsl:value-of select="'classification'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated( string(@ism:classification), document('../../CVE/ISM/CVEnumISMClassificationAll.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE, true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M257"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M257"/>
   <xsl:template match="@*|node()" priority="-2" mode="M257">
      <xsl:apply-templates select="*" mode="M257"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00173-->


	<!--RULE ISM-ID-00173-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                          and util:containsAnyTokenMatching(@ism:atomicEnergyMarkings, ('^RD-SG', '^FRD-SG'))]"
                 priority="1000"
                 mode="M258">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                          and util:containsAnyTokenMatching(@ism:atomicEnergyMarkings, ('^RD-SG', '^FRD-SG'))]"
                       id="ISM-ID-00173-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:classification = ('S','TS')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:classification = ('S','TS')">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [ISM-ID-00173][Error] If
            ISM_USGOV_RESOURCE and attribute atomicEnergyMarkings contains a name token starting
            with [RD-SG] or [FRD-SG], then attribute classification must have a value of [S] or
            [TS]. Human Readable: Portions in a USA document that contain RD or FRD SIGMA data must
            be marked SECRET or TOP SECRET. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M258"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M258"/>
   <xsl:template match="@*|node()" priority="-2" mode="M258">
      <xsl:apply-templates select="*" mode="M258"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00174-->


	<!--RULE ISM-ID-00174-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                      and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD', 'FRD', 'TFNI'))]"
                 priority="1000"
                 mode="M259">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                      and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD', 'FRD', 'TFNI'))]"
                       id="ISM-ID-00174-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:classification = ('TS','S','C')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:classification = ('TS','S','C')">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00174][Error] If ISM_USGOV_RESOURCE and attribute 
        atomicEnergyMarkings contains the name token [RD], [FRD], or [TFNI], 
        then attribute classification must have a value of [TS], [S], or [C].
        
        Human Readable: USA documents with RD, FRD, or TFNI data must be marked CONFIDENTIAL,
        SECRET, or TOP SECRET.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M259"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M259"/>
   <xsl:template match="@*|node()" priority="-2" mode="M259">
      <xsl:apply-templates select="*" mode="M259"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00175-->


	<!--RULE ISM-ID-00175-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                        and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD-CNWDI'))]"
                 priority="1000"
                 mode="M260">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                        and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD-CNWDI'))]"
                       id="ISM-ID-00175-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:classification = ('TS','S')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:classification = ('TS','S')">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00175][Error] If ISM_USGOV_RESOURCE and attribute 
			atomicEnergyMarkings contains the name token [RD-CNWDI], then attribute 
			classification must have a value of [TS] or [S].
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M260"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M260"/>
   <xsl:template match="@*|node()" priority="-2" mode="M260">
      <xsl:apply-templates select="*" mode="M260"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00176-->


	<!--RULE ISM-ID-00176-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                        and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD', 'FRD'))]"
                 priority="1000"
                 mode="M261">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                        and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD', 'FRD'))]"
                       id="ISM-ID-00176-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not($ISM_RESOURCE_ELEMENT/@ism:declassDate or $ISM_RESOURCE_ELEMENT/@ism:declassEvent)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($ISM_RESOURCE_ELEMENT/@ism:declassDate or $ISM_RESOURCE_ELEMENT/@ism:declassEvent)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>

        	[ISM-ID-00176][Error] Automatic declassification of documents containing 

        	RD or FRD information is prohibited. Attributes declassDate and 

        	declassEvent cannot be used in the classification authority block when 

        	RD or FRD is present.

        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M261"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M261"/>
   <xsl:template match="@*|node()" priority="-2" mode="M261">
      <xsl:apply-templates select="*" mode="M261"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00178-->


	<!--RULE ValuesOrderedAccordingToCve-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:atomicEnergyMarkings]"
                 priority="1000"
                 mode="M262">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:atomicEnergyMarkings]"
                       id="ValuesOrderedAccordingToCve-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count(tokenize(util:unsortedValues(@ism:atomicEnergyMarkings, $atomicEnergyMarkingsList),' ')) = 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(util:unsortedValues(@ism:atomicEnergyMarkings, $atomicEnergyMarkingsList),' ')) = 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'     [ISM-ID-00178][Error] If ISM_USGOV_RESOURCE and attribute      atomicEnergyMarkings is specified, then each of its values must be ordered in accordance with      CVEnumISMAtomicEnergyMarkings.xml.     '"/>
                  <xsl:text/>
      The following values are out of order [<xsl:text/>
                  <xsl:value-of select="util:unsortedValues(@ism:atomicEnergyMarkings, $atomicEnergyMarkingsList)"/>
                  <xsl:text/>] for [<xsl:text/>
                  <xsl:value-of select="@ism:atomicEnergyMarkings"/>
                  <xsl:text/>]
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M262"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M262"/>
   <xsl:template match="@*|node()" priority="-2" mode="M262">
      <xsl:apply-templates select="*" mode="M262"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00179-->


	<!--RULE AttributeValueDeprecatedWarning-R1-->
<xsl:template match="*[@ism:disseminationControls]" priority="1000" mode="M263">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls]"
                       id="AttributeValueDeprecatedWarning-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:disseminationControls), document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:disseminationControls), document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00179'"/>
                  <xsl:text/>][Warning] For attribute <xsl:text/>
                  <xsl:value-of select="'disseminationControls'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated(string(@ism:disseminationControls), document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE,false())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M263"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M263"/>
   <xsl:template match="@*|node()" priority="-2" mode="M263">
      <xsl:apply-templates select="*" mode="M263"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00180-->


	<!--RULE AttributeValueDeprecatedError-R1-->
<xsl:template match="*[@ism:disseminationControls]" priority="1000" mode="M264">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls]"
                       id="AttributeValueDeprecatedError-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:disseminationControls), document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:disseminationControls), document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00180'"/>
                  <xsl:text/>][Error] For attribute <xsl:text/>
                  <xsl:value-of select="'disseminationControls'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated( string(@ism:disseminationControls), document('../../CVE/ISM/CVEnumISMDissem.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE, true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M264"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M264"/>
   <xsl:template match="@*|node()" priority="-2" mode="M264">
      <xsl:apply-templates select="*" mode="M264"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00181-->


	<!--RULE ISM-ID-00181-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                      and @ism:atomicEnergyMarkings                      and not(@ism:classification='U')]"
                 priority="1000"
                 mode="M265">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                      and @ism:atomicEnergyMarkings                      and not(@ism:classification='U')]"
                       id="ISM-ID-00181-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('UCNI', 'DCNI')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('UCNI', 'DCNI')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        [ISM-ID-00181][Error] If ISM_USGOV_RESOURCE and element's 
        classification does not have a value of "U" then attribute atomicEnergyMarkings must not 
        contain the name token [UCNI] or [DCNI].
        
        Human Readable: UCNI and DCNI may only be used on UNCLASSIFIED portions.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M265"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M265"/>
   <xsl:template match="@*|node()" priority="-2" mode="M265">
      <xsl:apply-templates select="*" mode="M265"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00183-->


	<!--RULE ISM-ID-00183-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                      and util:containsAnyTokenMatching(@ism:atomicEnergyMarkings, ('^RD-SG'))]"
                 priority="1000"
                 mode="M266">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                      and util:containsAnyTokenMatching(@ism:atomicEnergyMarkings, ('^RD-SG'))]"
                       id="ISM-ID-00183-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00183][Error] If ISM_USGOV_RESOURCE and attribute 
      atomicEnergyMarkings contains a name token starting with [RD-SG],
      then it must also contain the name token [RD].
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M266"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M266"/>
   <xsl:template match="@*|node()" priority="-2" mode="M266">
      <xsl:apply-templates select="*" mode="M266"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00184-->


	<!--RULE ISM-ID-00184-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                      and util:containsAnyTokenMatching(@ism:atomicEnergyMarkings, ('^FRD-SG'))]"
                 priority="1000"
                 mode="M267">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                      and util:containsAnyTokenMatching(@ism:atomicEnergyMarkings, ('^FRD-SG'))]"
                       id="ISM-ID-00184-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('FRD'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('FRD'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00184][Error] If ISM_USGOV_RESOURCE and attribute 
			atomicEnergyMarkings contains a name token starting with [FRD-SG],
			then it must also contain the name token [FRD].
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M267"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M267"/>
   <xsl:template match="@*|node()" priority="-2" mode="M267">
      <xsl:apply-templates select="*" mode="M267"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00185-->


	<!--RULE ISM-ID-00185-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                      and util:containsAnyTokenMatching(@ism:atomicEnergyMarkings, ('RD-CNWDI'))]"
                 priority="1000"
                 mode="M268">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                      and util:containsAnyTokenMatching(@ism:atomicEnergyMarkings, ('RD-CNWDI'))]"
                       id="ISM-ID-00185-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00185][Error] If ISM_USGOV_RESOURCE and attribute 
			atomicEnergyMarkings contains the name token [RD-CNWDI],
			then it must also contain the name token [RD].
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M268"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M268"/>
   <xsl:template match="@*|node()" priority="-2" mode="M268">
      <xsl:apply-templates select="*" mode="M268"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00186-->


	<!--RULE ISM-ID-00186-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^SI-G-[A-Z]{4}$'))]"
                 priority="1000"
                 mode="M269">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^SI-G-[A-Z]{4}$'))]"
                       id="ISM-ID-00186-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-G'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-G'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>

          [ISM-ID-00186][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains a token matching [SI-G-XXXX],
          where X is represented by the regular expression character class [A-Z]{4}, then it must also contain the
          name token [SI-G].
          
          Human Readable: A USA document that contains Special Intelligence (SI) GAMMA sub-compartments must
          also specify that it contains SI-GAMMA compartment data.

        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M269"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M269"/>
   <xsl:template match="@*|node()" priority="-2" mode="M269">
      <xsl:apply-templates select="*" mode="M269"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00187-->


	<!--RULE ISM-ID-00187-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-G'))]"
                 priority="1000"
                 mode="M270">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-G'))]"
                       id="ISM-ID-00187-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>

          [ISM-ID-00187][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [SI-G],
          then it must also contain the name token [SI].
          
          Human Readable: A USA document that contains Special Intelligence (SI) -GAMMA compartment data must also specify that 
          it contains SI data. 

        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M270"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M270"/>
   <xsl:template match="@*|node()" priority="-2" mode="M270">
      <xsl:apply-templates select="*" mode="M270"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00188-->


	<!--RULE AttributeValueDeprecatedWarning-R1-->
<xsl:template match="*[@ism:FGIsourceOpen]" priority="1000" mode="M271">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:FGIsourceOpen]"
                       id="AttributeValueDeprecatedWarning-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:FGIsourceOpen), document('../../CVE/ISMCAT/CVEnumISMCATFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:FGIsourceOpen), document('../../CVE/ISMCAT/CVEnumISMCATFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00188'"/>
                  <xsl:text/>][Warning] For attribute <xsl:text/>
                  <xsl:value-of select="'FGIsourceOpen'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated(string(@ism:FGIsourceOpen), document('../../CVE/ISMCAT/CVEnumISMCATFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE,false())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M271"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M271"/>
   <xsl:template match="@*|node()" priority="-2" mode="M271">
      <xsl:apply-templates select="*" mode="M271"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00189-->


	<!--RULE AttributeValueDeprecatedError-R1-->
<xsl:template match="*[@ism:FGIsourceOpen]" priority="1000" mode="M272">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:FGIsourceOpen]"
                       id="AttributeValueDeprecatedError-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:FGIsourceOpen), document('../../CVE/ISMCAT/CVEnumISMCATFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:FGIsourceOpen), document('../../CVE/ISMCAT/CVEnumISMCATFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00189'"/>
                  <xsl:text/>][Error] For attribute <xsl:text/>
                  <xsl:value-of select="'FGIsourceOpen'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated( string(@ism:FGIsourceOpen), document('../../CVE/ISMCAT/CVEnumISMCATFGIOpen.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE, true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M272"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M272"/>
   <xsl:template match="@*|node()" priority="-2" mode="M272">
      <xsl:apply-templates select="*" mode="M272"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00190-->


	<!--RULE AttributeValueDeprecatedWarning-R1-->
<xsl:template match="*[@ism:FGIsourceProtected]" priority="1000" mode="M273">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:FGIsourceProtected]"
                       id="AttributeValueDeprecatedWarning-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:FGIsourceProtected), document('../../CVE/ISMCAT/CVEnumISMCATFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:FGIsourceProtected), document('../../CVE/ISMCAT/CVEnumISMCATFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00190'"/>
                  <xsl:text/>][Warning] For attribute <xsl:text/>
                  <xsl:value-of select="'FGIsourceProtected'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated(string(@ism:FGIsourceProtected), document('../../CVE/ISMCAT/CVEnumISMCATFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE,false())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M273"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M273"/>
   <xsl:template match="@*|node()" priority="-2" mode="M273">
      <xsl:apply-templates select="*" mode="M273"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00191-->


	<!--RULE AttributeValueDeprecatedError-R1-->
<xsl:template match="*[@ism:FGIsourceProtected]" priority="1000" mode="M274">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:FGIsourceProtected]"
                       id="AttributeValueDeprecatedError-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:FGIsourceProtected), document('../../CVE/ISMCAT/CVEnumISMCATFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:FGIsourceProtected), document('../../CVE/ISMCAT/CVEnumISMCATFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00191'"/>
                  <xsl:text/>][Error] For attribute <xsl:text/>
                  <xsl:value-of select="'FGIsourceProtected'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated( string(@ism:FGIsourceProtected), document('../../CVE/ISMCAT/CVEnumISMCATFGIProtected.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE, true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M274"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M274"/>
   <xsl:template match="@*|node()" priority="-2" mode="M274">
      <xsl:apply-templates select="*" mode="M274"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00192-->


	<!--RULE AttributeValueDeprecatedWarning-R1-->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M275">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:nonICmarkings]"
                       id="AttributeValueDeprecatedWarning-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:nonICmarkings), document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:nonICmarkings), document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00192'"/>
                  <xsl:text/>][Warning] For attribute <xsl:text/>
                  <xsl:value-of select="'nonICmarkings'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated(string(@ism:nonICmarkings), document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE,false())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M275"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M275"/>
   <xsl:template match="@*|node()" priority="-2" mode="M275">
      <xsl:apply-templates select="*" mode="M275"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00193-->


	<!--RULE AttributeValueDeprecatedError-R1-->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M276">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:nonICmarkings]"
                       id="AttributeValueDeprecatedError-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:nonICmarkings), document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:nonICmarkings), document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00193'"/>
                  <xsl:text/>][Error] For attribute <xsl:text/>
                  <xsl:value-of select="'nonICmarkings'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated( string(@ism:nonICmarkings), document('../../CVE/ISM/CVEnumISMNonIC.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE, true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M276"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M276"/>
   <xsl:template match="@*|node()" priority="-2" mode="M276">
      <xsl:apply-templates select="*" mode="M276"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00196-->


	<!--RULE AttributeValueDeprecatedWarning-R1-->
<xsl:template match="*[@ism:ownerProducer]" priority="1000" mode="M277">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:ownerProducer]"
                       id="AttributeValueDeprecatedWarning-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:ownerProducer), document('../../CVE/ISMCAT/CVEnumISMCATOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:ownerProducer), document('../../CVE/ISMCAT/CVEnumISMCATOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00196'"/>
                  <xsl:text/>][Warning] For attribute <xsl:text/>
                  <xsl:value-of select="'ownerProducer'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated(string(@ism:ownerProducer), document('../../CVE/ISMCAT/CVEnumISMCATOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE,false())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M277"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M277"/>
   <xsl:template match="@*|node()" priority="-2" mode="M277">
      <xsl:apply-templates select="*" mode="M277"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00197-->


	<!--RULE AttributeValueDeprecatedError-R1-->
<xsl:template match="*[@ism:ownerProducer]" priority="1000" mode="M278">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:ownerProducer]"
                       id="AttributeValueDeprecatedError-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:ownerProducer), document('../../CVE/ISMCAT/CVEnumISMCATOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:ownerProducer), document('../../CVE/ISMCAT/CVEnumISMCATOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00197'"/>
                  <xsl:text/>][Error] For attribute <xsl:text/>
                  <xsl:value-of select="'ownerProducer'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated( string(@ism:ownerProducer), document('../../CVE/ISMCAT/CVEnumISMCATOwnerProducer.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE, true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M278"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M278"/>
   <xsl:template match="@*|node()" priority="-2" mode="M278">
      <xsl:apply-templates select="*" mode="M278"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00198-->


	<!--RULE AttributeValueDeprecatedWarning-R1-->
<xsl:template match="*[@ism:releasableTo]" priority="1000" mode="M279">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:releasableTo]"
                       id="AttributeValueDeprecatedWarning-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:releasableTo), document('../../CVE/ISMCAT/CVEnumISMCATRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:releasableTo), document('../../CVE/ISMCAT/CVEnumISMCATRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00198'"/>
                  <xsl:text/>][Warning] For attribute <xsl:text/>
                  <xsl:value-of select="'releasableTo'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated(string(@ism:releasableTo), document('../../CVE/ISMCAT/CVEnumISMCATRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE,false())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M279"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M279"/>
   <xsl:template match="@*|node()" priority="-2" mode="M279">
      <xsl:apply-templates select="*" mode="M279"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00199-->


	<!--RULE AttributeValueDeprecatedError-R1-->
<xsl:template match="*[@ism:releasableTo]" priority="1000" mode="M280">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:releasableTo]"
                       id="AttributeValueDeprecatedError-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:releasableTo), document('../../CVE/ISMCAT/CVEnumISMCATRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:releasableTo), document('../../CVE/ISMCAT/CVEnumISMCATRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00199'"/>
                  <xsl:text/>][Error] For attribute <xsl:text/>
                  <xsl:value-of select="'releasableTo'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated( string(@ism:releasableTo), document('../../CVE/ISMCAT/CVEnumISMCATRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE, true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M280"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M280"/>
   <xsl:template match="@*|node()" priority="-2" mode="M280">
      <xsl:apply-templates select="*" mode="M280"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00200-->


	<!--RULE AttributeValueDeprecatedWarning-R1-->
<xsl:template match="*[@ism:displayOnlyTo]" priority="1000" mode="M281">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:displayOnlyTo]"
                       id="AttributeValueDeprecatedWarning-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:displayOnlyTo), document('../../CVE/ISMCAT/CVEnumISMCATRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:displayOnlyTo), document('../../CVE/ISMCAT/CVEnumISMCATRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00200'"/>
                  <xsl:text/>][Warning] For attribute <xsl:text/>
                  <xsl:value-of select="'displayOnlyTo'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated(string(@ism:displayOnlyTo), document('../../CVE/ISMCAT/CVEnumISMCATRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE,false())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M281"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M281"/>
   <xsl:template match="@*|node()" priority="-2" mode="M281">
      <xsl:apply-templates select="*" mode="M281"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00201-->


	<!--RULE AttributeValueDeprecatedError-R1-->
<xsl:template match="*[@ism:displayOnlyTo]" priority="1000" mode="M282">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:displayOnlyTo]"
                       id="AttributeValueDeprecatedError-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:displayOnlyTo), document('../../CVE/ISMCAT/CVEnumISMCATRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:displayOnlyTo), document('../../CVE/ISMCAT/CVEnumISMCATRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00201'"/>
                  <xsl:text/>][Error] For attribute <xsl:text/>
                  <xsl:value-of select="'displayOnlyTo'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated( string(@ism:displayOnlyTo), document('../../CVE/ISMCAT/CVEnumISMCATRelTo.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE, true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M282"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M282"/>
   <xsl:template match="@*|node()" priority="-2" mode="M282">
      <xsl:apply-templates select="*" mode="M282"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00202-->


	<!--RULE AttributeValueDeprecatedWarning-R1-->
<xsl:template match="*[@ism:SARIdentifier]" priority="1000" mode="M283">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:SARIdentifier]"
                       id="AttributeValueDeprecatedWarning-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:SARIdentifier), document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:SARIdentifier), document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00202'"/>
                  <xsl:text/>][Warning] For attribute <xsl:text/>
                  <xsl:value-of select="'SARIdentifier'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated(string(@ism:SARIdentifier), document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE,false())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M283"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M283"/>
   <xsl:template match="@*|node()" priority="-2" mode="M283">
      <xsl:apply-templates select="*" mode="M283"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00203-->


	<!--RULE AttributeValueDeprecatedError-R1-->
<xsl:template match="*[@ism:SARIdentifier]" priority="1000" mode="M284">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:SARIdentifier]"
                       id="AttributeValueDeprecatedError-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:SARIdentifier), document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:SARIdentifier), document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00203'"/>
                  <xsl:text/>][Error] For attribute <xsl:text/>
                  <xsl:value-of select="'SARIdentifier'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated( string(@ism:SARIdentifier), document('../../CVE/ISM/CVEnumISMSAR.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE, true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M284"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M284"/>
   <xsl:template match="@*|node()" priority="-2" mode="M284">
      <xsl:apply-templates select="*" mode="M284"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00204-->


	<!--RULE AttributeValueDeprecatedWarning-R1-->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M285">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:SCIcontrols]"
                       id="AttributeValueDeprecatedWarning-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:SCIcontrols), document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:SCIcontrols), document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00204'"/>
                  <xsl:text/>][Warning] For attribute <xsl:text/>
                  <xsl:value-of select="'SCIcontrols'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated(string(@ism:SCIcontrols), document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE,false())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M285"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M285"/>
   <xsl:template match="@*|node()" priority="-2" mode="M285">
      <xsl:apply-templates select="*" mode="M285"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00205-->


	<!--RULE AttributeValueDeprecatedError-R1-->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M286">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:SCIcontrols]"
                       id="AttributeValueDeprecatedError-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:SCIcontrols), document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:SCIcontrols), document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00205'"/>
                  <xsl:text/>][Error] For attribute <xsl:text/>
                  <xsl:value-of select="'SCIcontrols'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated( string(@ism:SCIcontrols), document('../../CVE/ISM/CVEnumISMSCIControls.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE, true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M286"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M286"/>
   <xsl:template match="@*|node()" priority="-2" mode="M286">
      <xsl:apply-templates select="*" mode="M286"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00206-->


	<!--RULE AttributeValueDeprecatedWarning-R1-->
<xsl:template match="*[@ism:declassException]" priority="1000" mode="M287">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:declassException]"
                       id="AttributeValueDeprecatedWarning-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:declassException), document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:declassException), document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00206'"/>
                  <xsl:text/>][Warning] For attribute <xsl:text/>
                  <xsl:value-of select="'declassException'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated(string(@ism:declassException), document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE,false())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M287"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M287"/>
   <xsl:template match="@*|node()" priority="-2" mode="M287">
      <xsl:apply-templates select="*" mode="M287"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00207-->


	<!--RULE AttributeValueDeprecatedError-R1-->
<xsl:template match="*[@ism:declassException]" priority="1000" mode="M288">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:declassException]"
                       id="AttributeValueDeprecatedError-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:declassException), document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:declassException), document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00207'"/>
                  <xsl:text/>][Error] For attribute <xsl:text/>
                  <xsl:value-of select="'declassException'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated( string(@ism:declassException), document('../../CVE/ISM/CVEnumISM25X.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE, true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M288"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M288"/>
   <xsl:template match="@*|node()" priority="-2" mode="M288">
      <xsl:apply-templates select="*" mode="M288"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00208-->


	<!--RULE AttributeValueDeprecatedWarning-R1-->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M289">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"
                       id="AttributeValueDeprecatedWarning-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:atomicEnergyMarkings), document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:atomicEnergyMarkings), document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00208'"/>
                  <xsl:text/>][Warning] For attribute <xsl:text/>
                  <xsl:value-of select="'atomicEnergyMarkings'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated(string(@ism:atomicEnergyMarkings), document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE,false())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M289"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M289"/>
   <xsl:template match="@*|node()" priority="-2" mode="M289">
      <xsl:apply-templates select="*" mode="M289"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00209-->


	<!--RULE AttributeValueDeprecatedError-R1-->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M290">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"
                       id="AttributeValueDeprecatedError-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:atomicEnergyMarkings), document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:atomicEnergyMarkings), document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00209'"/>
                  <xsl:text/>][Error] For attribute <xsl:text/>
                  <xsl:value-of select="'atomicEnergyMarkings'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated( string(@ism:atomicEnergyMarkings), document('../../CVE/ISM/CVEnumISMAtomicEnergyMarkings.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE, true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M290"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M290"/>
   <xsl:template match="@*|node()" priority="-2" mode="M290">
      <xsl:apply-templates select="*" mode="M290"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00210-->


	<!--RULE AttributeValueDeprecatedWarning-R1-->
<xsl:template match="*[@ism:nonUSControls]" priority="1000" mode="M291">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:nonUSControls]"
                       id="AttributeValueDeprecatedWarning-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:nonUSControls), document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:nonUSControls), document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00210'"/>
                  <xsl:text/>][Warning] For attribute <xsl:text/>
                  <xsl:value-of select="'nonUSControls'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated(string(@ism:nonUSControls), document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE,false())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M291"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M291"/>
   <xsl:template match="@*|node()" priority="-2" mode="M291">
      <xsl:apply-templates select="*" mode="M291"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00211-->


	<!--RULE AttributeValueDeprecatedError-R1-->
<xsl:template match="*[@ism:nonUSControls]" priority="1000" mode="M292">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:nonUSControls]"
                       id="AttributeValueDeprecatedError-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:nonUSControls), document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:nonUSControls), document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00211'"/>
                  <xsl:text/>][Error] For attribute <xsl:text/>
                  <xsl:value-of select="'nonUSControls'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated( string(@ism:nonUSControls), document('../../CVE/ISM/CVEnumISMNonUSControls.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE, true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M292"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M292"/>
   <xsl:template match="@*|node()" priority="-2" mode="M292">
      <xsl:apply-templates select="*" mode="M292"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00213-->


	<!--RULE ISM-ID-00213-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                       and util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY'))]"
                 priority="1000"
                 mode="M293">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                       and util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY'))]"
                       id="ISM-ID-00213-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:displayOnlyTo"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:displayOnlyTo">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00213][Error] If ISM_USGOV_RESOURCE and attribute 
        	disseminationControls contains the name token [DISPLAYONLY], then 
        	attribute displayOnlyTo must be specified.
        	
        	Human Readable: A USA document with DISPLAY ONLY dissemination must 
        	indicate the countries to which it may be disclosed.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M293"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M293"/>
   <xsl:template match="@*|node()" priority="-2" mode="M293">
      <xsl:apply-templates select="*" mode="M293"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00214-->


	<!--RULE ISM-ID-00214-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:releasableTo]"
                 priority="1000"
                 mode="M294">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:releasableTo]"
                       id="ISM-ID-00214-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="index-of(tokenize(normalize-space(string(@ism:releasableTo)),' '),'USA')=1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of(tokenize(normalize-space(string(@ism:releasableTo)),' '),'USA')=1">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>

            [ISM-ID-00214][Error] If ISM_USGOV_RESOURCE then attribute 

            releasableTo must start with [USA].

        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M294"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M294"/>
   <xsl:template match="@*|node()" priority="-2" mode="M294">
      <xsl:apply-templates select="*" mode="M294"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00217-->


	<!--RULE ISM-ID-00217-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:FGIsourceProtected]"
                 priority="1000"
                 mode="M295">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:FGIsourceProtected]"
                       id="ISM-ID-00217-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="normalize-space(string(@ism:FGIsourceProtected))='FGI'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="normalize-space(string(@ism:FGIsourceProtected))='FGI'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>

        	[ISM-ID-00217][Error] If ISM_USGOV_RESOURCE attribute FGIsourceProtected
        	contains [FGI], it must be the only value.

        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M295"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M295"/>
   <xsl:template match="@*|node()" priority="-2" mode="M295">
      <xsl:apply-templates select="*" mode="M295"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00219-->


	<!--RULE ISM-ID-00219-R1-->
<xsl:template match="*[not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))                         and util:contributesToRollup(.)                         and util:containsAnyOfTheTokens(@ism:ownerProducer, ('FGI'))]"
                 priority="1000"
                 mode="M296">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))                         and util:contributesToRollup(.)                         and util:containsAnyOfTheTokens(@ism:ownerProducer, ('FGI'))]"
                       id="ISM-ID-00219-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:FGIsourceProtected, ('FGI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:FGIsourceProtected, ('FGI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00219][Error] If element meets ISM_CONTRIBUTES and attribute
            ownerProducer contains the token [FGI], then attribute 
            FGIsourceProtected must have a value containing the token [FGI].
            
            Human Readable: Any non-resource element that contributes to the 
            document's banner roll-up and has FOREIGN GOVERNMENT INFORMATION (FGI)
            must also specify attribute FGIsourceProtected with token FGI.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M296"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M296"/>
   <xsl:template match="@*|node()" priority="-2" mode="M296">
      <xsl:apply-templates select="*" mode="M296"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00221-->


	<!--RULE ISM-ID-00221-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:derivativelyClassifiedBy]"
                 priority="1000"
                 mode="M297">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:derivativelyClassifiedBy]"
                       id="ISM-ID-00221-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(@ism:classificationReason or @ism:classifiedBy)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@ism:classificationReason or @ism:classifiedBy)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00221][Error] If ISM_USGOV_RESOURCE and attribute 
        	derivativelyClassifiedBy is specified, then attributes classificationReason
        	or classifiedBy must not be specified.
        	
        	Human Readable: USA documents that are derivatively classified must not
        	specify a classification reason or classified by.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M297"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M297"/>
   <xsl:template match="@*|node()" priority="-2" mode="M297">
      <xsl:apply-templates select="*" mode="M297"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00223-->


	<!--RULE ValidateValueExistenceInList-R1-->
<xsl:template match="ism:*" priority="1000" mode="M298">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="ism:*"
                       id="ValidateValueExistenceInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="some $token in $validElementList satisfies $token = local-name()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $token in $validElementList satisfies $token = local-name()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00223][Error] If any elements in namespace    urn:us:gov:ic:ism exist, the local name must exist in CVEnumISMElements.xml.       Human Readable: Ensure that elements in the ISM namespace are defined by ISM.XML.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M298"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M298"/>
   <xsl:template match="@*|node()" priority="-2" mode="M298">
      <xsl:apply-templates select="*" mode="M298"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00226-->


	<!--RULE ISM-ID-00226-R1-->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M299">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:noticeType]"
                       id="ISM-ID-00226-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(@ism:unregisteredNoticeType)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(@ism:unregisteredNoticeType)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00226][Error]
            @ism:noticeType and @ism:unregisteredNoticeType may not both be 
            applied to the same element.
            
            Human Readable: The ISM attributes noticeType and unregisteredNoticeType 
            are mutually exclusive and cannot both be applied to the same element. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M299"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M299"/>
   <xsl:template match="@*|node()" priority="-2" mode="M299">
      <xsl:apply-templates select="*" mode="M299"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00228-->


	<!--RULE ISM-ID-00228-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('FRD'))]"
                 priority="1000"
                 mode="M300">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('FRD'))]"
                       id="ISM-ID-00228-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="index-of($partAtomicEnergyMarkings_tok,'FRD')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partAtomicEnergyMarkings_tok,'FRD')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00228][Error] USA documents marked FRD at the resource level must have FRD data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M300"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M300"/>
   <xsl:template match="@*|node()" priority="-2" mode="M300">
      <xsl:apply-templates select="*" mode="M300"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00229-->


	<!--RULE ISM-ID-00229-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))]"
                 priority="1000"
                 mode="M301">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD'))]"
                       id="ISM-ID-00229-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="index-of($partAtomicEnergyMarkings_tok,'RD')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partAtomicEnergyMarkings_tok,'RD')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00229][Error] USA documents marked RD at the resource level must have RD data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M301"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M301"/>
   <xsl:template match="@*|node()" priority="-2" mode="M301">
      <xsl:apply-templates select="*" mode="M301"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00230-->


	<!--RULE ISM-ID-00230-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M302">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                       id="ISM-ID-00230-R1"/>
      <xsl:variable name="matchingTokens"
                    select="           for $token in tokenize(normalize-space(string(@ism:atomicEnergyMarkings)), ' ') return             if(matches($token,'^FRD-SG-[1-9][0-9]?$'))             then $token             else null           "/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $token in $matchingTokens satisfies                             index-of($partAtomicEnergyMarkings_tok, $token) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $token in $matchingTokens satisfies index-of($partAtomicEnergyMarkings_tok, $token) &gt; 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00230][Error] USA documents marked FRD-SG-## at the resource level must have FRD-SG-## data, where ## is the same.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M302"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M302"/>
   <xsl:template match="@*|node()" priority="-2" mode="M302">
      <xsl:apply-templates select="*" mode="M302"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00231-->


	<!--RULE ISM-ID-00231-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                 priority="1000"
                 mode="M303">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)]"
                       id="ISM-ID-00231-R1"/>
      <xsl:variable name="matchingTokens"
                    select="for $token in tokenize(normalize-space(string(@ism:atomicEnergyMarkings)), ' ') return                             if(matches($token,'^RD-SG-[1-9][0-9]?$')) then $token else null"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $token in $matchingTokens satisfies                    (index-of($partAtomicEnergyMarkings_tok, $token) &gt; 0 or                     index-of($partAtomicEnergyMarkings_tok, concat('F', $token)) &gt; 0)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $token in $matchingTokens satisfies (index-of($partAtomicEnergyMarkings_tok, $token) &gt; 0 or index-of($partAtomicEnergyMarkings_tok, concat('F', $token)) &gt; 0)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        [ISM-ID-00231][Error] USA documents marked RD-SG-## at the resource level must have RD-SG-## or FRD-SG-## data, where ## is the same.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M303"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M303"/>
   <xsl:template match="@*|node()" priority="-2" mode="M303">
      <xsl:apply-templates select="*" mode="M303"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00241-->


	<!--RULE ISM-ID-00241-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('RSV-[A-Z0-9]{3}'))]"
                 priority="1000"
                 mode="M304">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('RSV-[A-Z0-9]{3}'))]"
                       id="ISM-ID-00241-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('RSV'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('RSV'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00241][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [RSV-XXX],
            then it must also contain the name token [RSV].
            
            Human Readable: A USA document that contains RESERVE data (RSV) compartment data must also specify that 
            it contains RSV data. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M304"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M304"/>
   <xsl:template match="@*|node()" priority="-2" mode="M304">
      <xsl:apply-templates select="*" mode="M304"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00242-->


	<!--RULE ISM-ID-00242-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('RSV'))]"
                 priority="1000"
                 mode="M305">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('RSV'))]"
                       id="ISM-ID-00242-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00242][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [RSV],
            then it must also have attribute classification with a value of [S] or [TS].
            
            Human Readable: A USA document that contains RESERVE data must be classified SECRET or TOP SECRET. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M305"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M305"/>
   <xsl:template match="@*|node()" priority="-2" mode="M305">
      <xsl:apply-templates select="*" mode="M305"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00243-->


	<!--RULE ISM-ID-00243-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('RSV'))]"
                 priority="1000"
                 mode="M306">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('RSV'))]"
                       id="ISM-ID-00243-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyTokenMatching(@ism:SCIcontrols, ('RSV-[A-Z0-9]{3}'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyTokenMatching(@ism:SCIcontrols, ('RSV-[A-Z0-9]{3}'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00243][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [RSV],
      then it must also contain a compartment [RSV-XXX].
      
      Human Readable: RESERVE is not permitted as a stand-alone value and a compartment must be expressed.
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M306"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M306"/>
   <xsl:template match="@*|node()" priority="-2" mode="M306">
      <xsl:apply-templates select="*" mode="M306"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00244-->


	<!--RULE ISM-ID-00244-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                       and util:contributesToRollup(.)                       and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD-CNWDI'))]"
                 priority="1000"
                 mode="M307">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                       and util:contributesToRollup(.)                       and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD-CNWDI'))]"
                       id="ISM-ID-00244-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="       some $elem in $partTags satisfies         ($elem[@ism:noticeType]         and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('CNWDI'))         and not ($elem/@ism:externalNotice=true()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('CNWDI')) and not ($elem/@ism:externalNotice=true()))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00244][Error] If ISM_USGOV_RESOURCE and:
      1. Any element meeting ISM_CONTRIBUTES in the document has the attribute atomicEnergyMarkings containing [RD-CNWDI]
      AND
      2. No element meeting ISM_CONTRIBUTES in the document has noticeType containing [CNWDI].
      
      Human Readable: USA documents containing CNWDI data must also have an CNWDI notice.
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M307"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M307"/>
   <xsl:template match="@*|node()" priority="-2" mode="M307">
      <xsl:apply-templates select="*" mode="M307"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00245-->


	<!--RULE ISM-ID-00245-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:contributesToRollup(.)                         and (util:containsAnyOfTheTokens(@ism:noticeType, ('CNWDI')))                         and not (@ism:externalNotice=true())]"
                 priority="1000"
                 mode="M308">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:contributesToRollup(.)                         and (util:containsAnyOfTheTokens(@ism:noticeType, ('CNWDI')))                         and not (@ism:externalNotice=true())]"
                       id="ISM-ID-00245-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="index-of($partAtomicEnergyMarkings_tok, 'RD-CNWDI')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partAtomicEnergyMarkings_tok, 'RD-CNWDI')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00245][Error] If ISM_USGOV_RESOURCE and:
            1. No element without ism:excludeFromRollup=true() in the document has the attribute atomicEnergyMarkings containing [RD-CNWDI]
            AND
            2. Any element without ism:excludeFromRollup=true() in the document has the attribute noticeType containing [CNWDI]
            without the attribute externalNotice with a value of [true]
            
            Human Readable: USA documents containing an CNWDI notice must also have RD-CNWDI data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M308"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M308"/>
   <xsl:template match="@*|node()" priority="-2" mode="M308">
      <xsl:apply-templates select="*" mode="M308"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00246-->


	<!--RULE ISM-ID-00246-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD','FRD', 'TFNI'))]"
                 priority="1000"
                 mode="M309">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD','FRD', 'TFNI'))]"
                       id="ISM-ID-00246-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:declassException, ('AEA', 'NATO-AEA'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:declassException, ('AEA', 'NATO-AEA'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00246][Error] USA documents containing [RD], [FRD], or [TFNI] data must have declassException containing [AEA] or [NATO-AEA] at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M309"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M309"/>
   <xsl:template match="@*|node()" priority="-2" mode="M309">
      <xsl:apply-templates select="*" mode="M309"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00250-->


	<!--RULE ISM-ID-00250-R1-->
<xsl:template match="ism:Notice[$ISM_USGOV_RESOURCE]" priority="1000" mode="M310">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="ism:Notice[$ISM_USGOV_RESOURCE]"
                       id="ISM-ID-00250-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:noticeType or @ism:unregisteredNoticeType"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:noticeType or @ism:unregisteredNoticeType">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00250][Error] If ISM_USGOV_RESOURCE, element Notice must specify
			attribute ism:noticeType or ism:unregisteredNoticeType.
			
			Human Readable: Notices must specify their type.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M310"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M310"/>
   <xsl:template match="@*|node()" priority="-2" mode="M310">
      <xsl:apply-templates select="*" mode="M310"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00252-->


	<!--RULE ISM-ID-00252-R1-->
<xsl:template match="*[index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/         @ism:disseminationControls)), ' '),'RELIDO') &gt; 0 and @ism:nonICmarkings]"
                 priority="1000"
                 mode="M311">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[index-of(tokenize(normalize-space(string($ISM_RESOURCE_ELEMENT/         @ism:disseminationControls)), ' '),'RELIDO') &gt; 0 and @ism:nonICmarkings]"
                       id="ISM-ID-00252-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(util:containsAnyTokenMatching(@ism:nonICmarkings, 'NNPI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyTokenMatching(@ism:nonICmarkings, 'NNPI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00252][Error] If ISM_RESOURCE_ELEMENT specifies the attribute
            ism:disseminationControls with a value containing the token [RELIDO], 
            then attribute nonICmarkings must not be specified with a value containing 
            the token [NNPI]. 
        	
        	Human Readable: NNPI tokens are not valid for documents that have
        	RELIDO at the resource level.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M311"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M311"/>
   <xsl:template match="@*|node()" priority="-2" mode="M311">
      <xsl:apply-templates select="*" mode="M311"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00253-->


	<!--RULE ValidateTokenValuesExistenceInList-R1-->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M312">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"
                       id="ValidateTokenValuesExistenceInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:atomicEnergyMarkings)), ' ') satisfies                   $searchTerm = $atomicEnergyMarkingsList or (some $Term in $atomicEnergyMarkingsList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:atomicEnergyMarkings)), ' ') satisfies $searchTerm = $atomicEnergyMarkingsList or (some $Term in $atomicEnergyMarkingsList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00253][Error] All @ism:atomicEnergyMarkings values must   be defined in CVEnumISMAtomicEnergyMarkings.xml.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M312"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M312"/>
   <xsl:template match="@*|node()" priority="-2" mode="M312">
      <xsl:apply-templates select="*" mode="M312"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00254-->


	<!--RULE ValidateTokenValuesExistenceInList-R1-->
<xsl:template match="*[@ism:classification]" priority="1000" mode="M313">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:classification]"
                       id="ValidateTokenValuesExistenceInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:classification)), ' ') satisfies                   $searchTerm = $classificationAllList or (some $Term in $classificationAllList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:classification)), ' ') satisfies $searchTerm = $classificationAllList or (some $Term in $classificationAllList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00254][Error] All @ism:classification values must   be a defined in CVEnumISMClassificationAll.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M313"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M313"/>
   <xsl:template match="@*|node()" priority="-2" mode="M313">
      <xsl:apply-templates select="*" mode="M313"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00255-->


	<!--RULE ValidateTokenValuesExistenceInList-R1-->
<xsl:template match="*[@ism:exemptFrom]" priority="1000" mode="M314">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:exemptFrom]"
                       id="ValidateTokenValuesExistenceInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:exemptFrom)), ' ') satisfies                   $searchTerm = $exemptFromList or (some $Term in $exemptFromList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:exemptFrom)), ' ') satisfies $searchTerm = $exemptFromList or (some $Term in $exemptFromList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00255][Error] All @ism:exemptFrom values must be defined in CVEnumISMExemptFrom.xml.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M314"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M314"/>
   <xsl:template match="@*|node()" priority="-2" mode="M314">
      <xsl:apply-templates select="*" mode="M314"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00256-->


	<!--RULE ValidateTokenValuesExistenceInList-R1-->
<xsl:template match="*[@ism:declassException]" priority="1000" mode="M315">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:declassException]"
                       id="ValidateTokenValuesExistenceInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:declassException)), ' ') satisfies                   $searchTerm = $declassExceptionList or (some $Term in $declassExceptionList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:declassException)), ' ') satisfies $searchTerm = $declassExceptionList or (some $Term in $declassExceptionList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00256][Error] All @ism:declassException values must   be defined in CVEnumISM25X.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M315"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M315"/>
   <xsl:template match="@*|node()" priority="-2" mode="M315">
      <xsl:apply-templates select="*" mode="M315"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00257-->


	<!--RULE ValidateTokenValuesExistenceInList-R1-->
<xsl:template match="*[@ism:displayOnlyTo]" priority="1000" mode="M316">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:displayOnlyTo]"
                       id="ValidateTokenValuesExistenceInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:displayOnlyTo)), ' ') satisfies                   $searchTerm = $displayOnlyToList or (some $Term in $displayOnlyToList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:displayOnlyTo)), ' ') satisfies $searchTerm = $displayOnlyToList or (some $Term in $displayOnlyToList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00257][Error] All @ism:displayOnlyTo values must   be defined in CVEnumISMCATRelTo.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M316"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M316"/>
   <xsl:template match="@*|node()" priority="-2" mode="M316">
      <xsl:apply-templates select="*" mode="M316"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00258-->


	<!--RULE ValidateTokenValuesExistenceInList-R1-->
<xsl:template match="*[@ism:disseminationControls]" priority="1000" mode="M317">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls]"
                       id="ValidateTokenValuesExistenceInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:disseminationControls)), ' ') satisfies                   $searchTerm = $disseminationControlsList or (some $Term in $disseminationControlsList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:disseminationControls)), ' ') satisfies $searchTerm = $disseminationControlsList or (some $Term in $disseminationControlsList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00258][Error] All @ism:disseminationControls values must   be a defined in CVEnumISMDissem.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M317"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M317"/>
   <xsl:template match="@*|node()" priority="-2" mode="M317">
      <xsl:apply-templates select="*" mode="M317"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00259-->


	<!--RULE ValidateTokenValuesExistenceInList-R1-->
<xsl:template match="*[@ism:FGIsourceOpen]" priority="1000" mode="M318">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:FGIsourceOpen]"
                       id="ValidateTokenValuesExistenceInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:FGIsourceOpen)), ' ') satisfies                   $searchTerm = $FGIsourceOpenList or (some $Term in $FGIsourceOpenList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:FGIsourceOpen)), ' ') satisfies $searchTerm = $FGIsourceOpenList or (some $Term in $FGIsourceOpenList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00259][Error] All @ism:FGIsourceOpen values must   be defined in CVEnumISMCATFGIOpen.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M318"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M318"/>
   <xsl:template match="@*|node()" priority="-2" mode="M318">
      <xsl:apply-templates select="*" mode="M318"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00260-->


	<!--RULE ValidateTokenValuesExistenceInList-R1-->
<xsl:template match="*[@ism:FGIsourceProtected]" priority="1000" mode="M319">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:FGIsourceProtected]"
                       id="ValidateTokenValuesExistenceInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:FGIsourceProtected)), ' ') satisfies                   $searchTerm = $FGIsourceProtectedList or (some $Term in $FGIsourceProtectedList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:FGIsourceProtected)), ' ') satisfies $searchTerm = $FGIsourceProtectedList or (some $Term in $FGIsourceProtectedList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00260][Error] All @ism:FGIsourceProtected values must   be defined in CVEnumISMCATFGIProtected.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M319"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M319"/>
   <xsl:template match="@*|node()" priority="-2" mode="M319">
      <xsl:apply-templates select="*" mode="M319"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00261-->


	<!--RULE ValidateTokenValuesExistenceInListWhenContributesToRollupACCM-R1-->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M320">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:nonICmarkings]"
                       id="ValidateTokenValuesExistenceInListWhenContributesToRollupACCM-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="if (util:contributesToRollup(.)) then every $searchTerm in tokenize(normalize-space(string(@ism:nonICmarkings)), ' ') satisfies             $searchTerm = $nonICmarkingsList or (some $Term in $nonICmarkingsList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$')))) else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (util:contributesToRollup(.)) then every $searchTerm in tokenize(normalize-space(string(@ism:nonICmarkings)), ' ') satisfies $searchTerm = $nonICmarkingsList or (some $Term in $nonICmarkingsList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$')))) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00261][Error] All @ism:nonICmarkings values that contribute to rollup must be defined in CVEnumISMNonIC.xml.'"/>
                  <xsl:text/>
            The value(s) [<xsl:text/>
                  <xsl:value-of select="string-join(for $searchTerm in tokenize(normalize-space(string(@ism:nonICmarkings)), ' ')                  return if($searchTerm = $nonICmarkingsList) then null else $searchTerm,' ')"/>
                  <xsl:text/>] that contribute to rollup could not be found.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="if (not(util:contributesToRollup(.))) then every $searchTerm in tokenize(normalize-space(string(util:getStringFromSequenceWithoutRegexValues(tokenize(normalize-space(string(@ism:nonICmarkings)), ' '), $ACCMRegex))), ' ') satisfies             $searchTerm = tokenize(normalize-space(string(util:getStringFromSequenceWithoutRegexValues($nonICmarkingsList, $ACCMRegex))), ' ') or (some $Term in tokenize(normalize-space(string(util:getStringFromSequenceWithoutRegexValues($nonICmarkingsList, $ACCMRegex))), ' ') satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$')))) else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (not(util:contributesToRollup(.))) then every $searchTerm in tokenize(normalize-space(string(util:getStringFromSequenceWithoutRegexValues(tokenize(normalize-space(string(@ism:nonICmarkings)), ' '), $ACCMRegex))), ' ') satisfies $searchTerm = tokenize(normalize-space(string(util:getStringFromSequenceWithoutRegexValues($nonICmarkingsList, $ACCMRegex))), ' ') or (some $Term in tokenize(normalize-space(string(util:getStringFromSequenceWithoutRegexValues($nonICmarkingsList, $ACCMRegex))), ' ') satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$')))) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00261][Error] All non-ACCM @ism:nonICmarkings values that do not contribute to rollup must be defined in CVEnumISMNonIC.xml.'"/>
                  <xsl:text/>
            The value(s) [<xsl:text/>
                  <xsl:value-of select="string-join(for $searchTerm in tokenize(normalize-space(string(util:getStringFromSequenceWithoutRegexValues(tokenize(normalize-space(string(@ism:nonICmarkings)), ' '), $ACCMRegex))), ' ')                  return if($searchTerm = tokenize(normalize-space(string(util:getStringFromSequenceWithoutRegexValues($nonICmarkingsList, $ACCMRegex))), ' ')) then null else $searchTerm,' ')"/>
                  <xsl:text/>] that contribute to rollup could not be found.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M320"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M320"/>
   <xsl:template match="@*|node()" priority="-2" mode="M320">
      <xsl:apply-templates select="*" mode="M320"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00262-->


	<!--RULE ValidateTokenValuesExistenceInList-R1-->
<xsl:template match="*[@ism:nonUSControls]" priority="1000" mode="M321">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:nonUSControls]"
                       id="ValidateTokenValuesExistenceInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:nonUSControls)), ' ') satisfies                   $searchTerm = $nonUSControlsList or (some $Term in $nonUSControlsList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:nonUSControls)), ' ') satisfies $searchTerm = $nonUSControlsList or (some $Term in $nonUSControlsList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00262][Error] Any @ism:nonUSControls values must   be defined in CVEnumISMNonUSControls.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M321"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M321"/>
   <xsl:template match="@*|node()" priority="-2" mode="M321">
      <xsl:apply-templates select="*" mode="M321"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00263-->


	<!--RULE ValidateTokenValuesExistenceInList-R1-->
<xsl:template match="*[@ism:ownerProducer]" priority="1000" mode="M322">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:ownerProducer]"
                       id="ValidateTokenValuesExistenceInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:ownerProducer)), ' ') satisfies                   $searchTerm = $ownerProducerList or (some $Term in $ownerProducerList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:ownerProducer)), ' ') satisfies $searchTerm = $ownerProducerList or (some $Term in $ownerProducerList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00263][Error] Any @ism:ownerProducer values must   be defined in CVEnumISMCATOwnerProducer.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M322"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M322"/>
   <xsl:template match="@*|node()" priority="-2" mode="M322">
      <xsl:apply-templates select="*" mode="M322"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00264-->


	<!--RULE ValidateTokenValuesExistenceInList-R1-->
<xsl:template match="*[@ism:pocType]" priority="1000" mode="M323">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:pocType]"
                       id="ValidateTokenValuesExistenceInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:pocType)), ' ') satisfies                   $searchTerm = $pocTypeList or (some $Term in $pocTypeList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:pocType)), ' ') satisfies $searchTerm = $pocTypeList or (some $Term in $pocTypeList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00264][Error] Any @ism:pocType values must   be defined in CVEnumISMPocType.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M323"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M323"/>
   <xsl:template match="@*|node()" priority="-2" mode="M323">
      <xsl:apply-templates select="*" mode="M323"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00265-->


	<!--RULE ValidateTokenValuesExistenceInList-R1-->
<xsl:template match="*[@ism:releasableTo]" priority="1000" mode="M324">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:releasableTo]"
                       id="ValidateTokenValuesExistenceInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:releasableTo)), ' ') satisfies                   $searchTerm = $releasableToList or (some $Term in $releasableToList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:releasableTo)), ' ') satisfies $searchTerm = $releasableToList or (some $Term in $releasableToList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00265][Error] Any @ism:releasableTo must   be a value in CVEnumISMCATRelTo.xml.   '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M324"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M324"/>
   <xsl:template match="@*|node()" priority="-2" mode="M324">
      <xsl:apply-templates select="*" mode="M324"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00266-->


	<!--RULE ValidateTokenValuesExistenceInListWhenContributesToRollup-R1-->
<xsl:template match="*[@ism:SARIdentifier]" priority="1000" mode="M325">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:SARIdentifier]"
                       id="ValidateTokenValuesExistenceInListWhenContributesToRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="if (util:contributesToRollup(.)) then every $searchTerm in tokenize(normalize-space(string(@ism:SARIdentifier)), ' ') satisfies             $searchTerm = $SARIdentifierList or (some $Term in $SARIdentifierList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$')))) else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (util:contributesToRollup(.)) then every $searchTerm in tokenize(normalize-space(string(@ism:SARIdentifier)), ' ') satisfies $searchTerm = $SARIdentifierList or (some $Term in $SARIdentifierList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$')))) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00266][Error] All @ism:SARIdentifier values must be defined in CVEnumISMSAR.xml.'"/>
                  <xsl:text/>
            The value(s) [<xsl:text/>
                  <xsl:value-of select="string-join(for $searchTerm in tokenize(normalize-space(string(@ism:SARIdentifier)), ' ')                  return if($searchTerm = $SARIdentifierList) then null else $searchTerm,' ')"/>
                  <xsl:text/>] that contribute to rollup could not be found.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M325"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M325"/>
   <xsl:template match="@*|node()" priority="-2" mode="M325">
      <xsl:apply-templates select="*" mode="M325"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00267-->


	<!--RULE ValidateTokenValuesExistenceInListWhenContributesToRollup-R1-->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M326">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:SCIcontrols]"
                       id="ValidateTokenValuesExistenceInListWhenContributesToRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="if (util:contributesToRollup(.)) then every $searchTerm in tokenize(normalize-space(string(@ism:SCIcontrols)), ' ') satisfies             $searchTerm = $SCIcontrolsList or (some $Term in $SCIcontrolsList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$')))) else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if (util:contributesToRollup(.)) then every $searchTerm in tokenize(normalize-space(string(@ism:SCIcontrols)), ' ') satisfies $searchTerm = $SCIcontrolsList or (some $Term in $SCIcontrolsList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$')))) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00267][Error] All @ism:SCIcontrols values must be defined in CVEnumISMSCIControls.xml.'"/>
                  <xsl:text/>
            The value(s) [<xsl:text/>
                  <xsl:value-of select="string-join(for $searchTerm in tokenize(normalize-space(string(@ism:SCIcontrols)), ' ')                  return if($searchTerm = $SCIcontrolsList) then null else $searchTerm,' ')"/>
                  <xsl:text/>] that contribute to rollup could not be found.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M326"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M326"/>
   <xsl:template match="@*|node()" priority="-2" mode="M326">
      <xsl:apply-templates select="*" mode="M326"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00268-->


	<!--RULE ISM-ID-00268-R1-->
<xsl:template match="*[@ism:atomicEnergyMarkings]" priority="1000" mode="M327">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:atomicEnergyMarkings]"
                       id="ISM-ID-00268-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:atomicEnergyMarkings, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:atomicEnergyMarkings, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00268][Error] All atomicEnergyMarkings attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M327"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M327"/>
   <xsl:template match="@*|node()" priority="-2" mode="M327">
      <xsl:apply-templates select="*" mode="M327"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00269-->


	<!--RULE ISM-ID-00269-R1-->
<xsl:template match="*[@ism:classification]" priority="1000" mode="M328">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:classification]"
                       id="ISM-ID-00269-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:classification, $NmTokenPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:classification, $NmTokenPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00269][Error] All classification attributes values must be of type NmToken. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M328"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M328"/>
   <xsl:template match="@*|node()" priority="-2" mode="M328">
      <xsl:apply-templates select="*" mode="M328"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00270-->


	<!--RULE ISM-ID-00270-R1-->
<xsl:template match="*[@ism:classificationReason]" priority="1000" mode="M329">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:classificationReason]"
                       id="ISM-ID-00270-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="string-length(@ism:classificationReason) &lt;= 4096"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(@ism:classificationReason) &lt;= 4096">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00270][Error] All classificationReason attributes must be a string with 4096
			characters or less. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M329"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M329"/>
   <xsl:template match="@*|node()" priority="-2" mode="M329">
      <xsl:apply-templates select="*" mode="M329"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00271-->


	<!--RULE ISM-ID-00271-R1-->
<xsl:template match="*[@ism:classifiedBy]" priority="1000" mode="M330">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:classifiedBy]"
                       id="ISM-ID-00271-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="string-length(@ism:classifiedBy) &lt;= 1024"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(@ism:classifiedBy) &lt;= 1024">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00271][Error] All classifiedBy attributes must be a string with less than 1024 characters. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M330"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M330"/>
   <xsl:template match="@*|node()" priority="-2" mode="M330">
      <xsl:apply-templates select="*" mode="M330"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00272-->


	<!--RULE ISM-ID-00272-R1-->
<xsl:template match="*[@ism:compilationReason]" priority="1000" mode="M331">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:compilationReason]"
                       id="ISM-ID-00272-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="string-length(@ism:compilationReason) &lt;= 1024"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(@ism:compilationReason) &lt;= 1024">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00272][Error] All compilationReason attributes must be a string with less than 1024 characters. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M331"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M331"/>
   <xsl:template match="@*|node()" priority="-2" mode="M331">
      <xsl:apply-templates select="*" mode="M331"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00273-->


	<!--RULE ISM-ID-00273-R1-->
<xsl:template match="*[@ism:exemptFrom]" priority="1000" mode="M332">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:exemptFrom]"
                       id="ISM-ID-00273-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:exemptFrom, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:exemptFrom, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00273][Error] All exemptFrom attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M332"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M332"/>
   <xsl:template match="@*|node()" priority="-2" mode="M332">
      <xsl:apply-templates select="*" mode="M332"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00274-->


	<!--RULE ISM-ID-00274-R1-->
<xsl:template match="*[@ism:createDate]" priority="1000" mode="M333">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:createDate]"
                       id="ISM-ID-00274-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:createDate, $DatePattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:createDate, $DatePattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00274][Error] All createDate attribute values must be of type Date. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="matches(@ism:createDate, '[0-9]{4}-[0-9]{2}-[0-9]{2}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(@ism:createDate, '[0-9]{4}-[0-9]{2}-[0-9]{2}$')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00274][Error] All createDate attribute values must not have any timezone
			information specified. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M333"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M333"/>
   <xsl:template match="@*|node()" priority="-2" mode="M333">
      <xsl:apply-templates select="*" mode="M333"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00275-->


	<!--RULE ISM-ID-00275-R1-->
<xsl:template match="*[@ism:declassDate]" priority="1000" mode="M334">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:declassDate]"
                       id="ISM-ID-00275-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:declassDate, $DatePattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:declassDate, $DatePattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00275][Error] All declassDate attributes values must be of type Date. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M334"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M334"/>
   <xsl:template match="@*|node()" priority="-2" mode="M334">
      <xsl:apply-templates select="*" mode="M334"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00276-->


	<!--RULE ISM-ID-00276-R1-->
<xsl:template match="*[@ism:declassEvent]" priority="1000" mode="M335">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:declassEvent]"
                       id="ISM-ID-00276-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="string-length(@ism:declassEvent) &lt;= 1024"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(@ism:declassEvent) &lt;= 1024">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00276][Error] All declassEvent attributes must be a string with less than 1024 characters. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M335"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M335"/>
   <xsl:template match="@*|node()" priority="-2" mode="M335">
      <xsl:apply-templates select="*" mode="M335"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00277-->


	<!--RULE ISM-ID-00277-R1-->
<xsl:template match="*[@ism:declassException]" priority="1000" mode="M336">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:declassException]"
                       id="ISM-ID-00277-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:declassException, $NmTokenPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:declassException, $NmTokenPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00277][Error] All declassException attributes values must be of type NmToken. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M336"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M336"/>
   <xsl:template match="@*|node()" priority="-2" mode="M336">
      <xsl:apply-templates select="*" mode="M336"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00278-->


	<!--RULE ISM-ID-00278-R1-->
<xsl:template match="*[@ism:derivativelyClassifiedBy]"
                 priority="1000"
                 mode="M337">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:derivativelyClassifiedBy]"
                       id="ISM-ID-00278-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="string-length(@ism:derivativelyClassifiedBy) &lt;= 1024"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(@ism:derivativelyClassifiedBy) &lt;= 1024">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00278][Error] All derivativelyClassifiedBy attributes must be a string with less than 1024 characters. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M337"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M337"/>
   <xsl:template match="@*|node()" priority="-2" mode="M337">
      <xsl:apply-templates select="*" mode="M337"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00279-->


	<!--RULE ISM-ID-00279-R1-->
<xsl:template match="*[@ism:derivedFrom]" priority="1000" mode="M338">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:derivedFrom]"
                       id="ISM-ID-00279-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="string-length(@ism:derivedFrom) &lt;= 1024"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(@ism:derivedFrom) &lt;= 1024">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00279][Error] All derivedFrom attributes must be a string with less than 1024 characters. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M338"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M338"/>
   <xsl:template match="@*|node()" priority="-2" mode="M338">
      <xsl:apply-templates select="*" mode="M338"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00280-->


	<!--RULE ISM-ID-00280-R1-->
<xsl:template match="*[@ism:displayOnlyTo]" priority="1000" mode="M339">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:displayOnlyTo]"
                       id="ISM-ID-00280-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:displayOnlyTo, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:displayOnlyTo, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00280][Error] All displayOnlyTo attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M339"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M339"/>
   <xsl:template match="@*|node()" priority="-2" mode="M339">
      <xsl:apply-templates select="*" mode="M339"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00281-->


	<!--RULE ISM-ID-00281-R1-->
<xsl:template match="*[@ism:disseminationControls]" priority="1000" mode="M340">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:disseminationControls]"
                       id="ISM-ID-00281-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:disseminationControls, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:disseminationControls, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00281][Error] All disseminationControls attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M340"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M340"/>
   <xsl:template match="@*|node()" priority="-2" mode="M340">
      <xsl:apply-templates select="*" mode="M340"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00282-->


	<!--RULE ISM-ID-00282-R1-->
<xsl:template match="*[@ism:excludeFromRollup]" priority="1000" mode="M341">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:excludeFromRollup]"
                       id="ISM-ID-00282-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:excludeFromRollup, $BooleanPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:excludeFromRollup, $BooleanPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00282][Error] All excludeFromRollup attributes values must be of type Boolean. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M341"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M341"/>
   <xsl:template match="@*|node()" priority="-2" mode="M341">
      <xsl:apply-templates select="*" mode="M341"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00283-->


	<!--RULE ISM-ID-00283-R1-->
<xsl:template match="*[@ism:FGIsourceOpen]" priority="1000" mode="M342">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:FGIsourceOpen]"
                       id="ISM-ID-00283-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:FGIsourceOpen, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:FGIsourceOpen, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00283][Error] All FGIsourceOpen attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M342"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M342"/>
   <xsl:template match="@*|node()" priority="-2" mode="M342">
      <xsl:apply-templates select="*" mode="M342"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00284-->


	<!--RULE ISM-ID-00284-R1-->
<xsl:template match="*[@ism:FGIsourceProtected]" priority="1000" mode="M343">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:FGIsourceProtected]"
                       id="ISM-ID-00284-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:FGIsourceProtected, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:FGIsourceProtected, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00284][Error] All FGIsourceProtected attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M343"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M343"/>
   <xsl:template match="@*|node()" priority="-2" mode="M343">
      <xsl:apply-templates select="*" mode="M343"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00285-->


	<!--RULE ISM-ID-00285-R1-->
<xsl:template match="*[@ism:nonICmarkings]" priority="1000" mode="M344">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:nonICmarkings]"
                       id="ISM-ID-00285-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:nonICmarkings, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:nonICmarkings, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00285][Error] All nonICmarkings attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M344"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M344"/>
   <xsl:template match="@*|node()" priority="-2" mode="M344">
      <xsl:apply-templates select="*" mode="M344"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00286-->


	<!--RULE ISM-ID-00286-R1-->
<xsl:template match="*[@ism:nonUSControls]" priority="1000" mode="M345">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:nonUSControls]"
                       id="ISM-ID-00286-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:nonUSControls, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:nonUSControls, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00286][Error] All nonUSControls attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M345"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M345"/>
   <xsl:template match="@*|node()" priority="-2" mode="M345">
      <xsl:apply-templates select="*" mode="M345"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00287-->


	<!--RULE ISM-ID-00287-R1-->
<xsl:template match="*[@ism:noticeDate]" priority="1000" mode="M346">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:noticeDate]"
                       id="ISM-ID-00287-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:noticeDate, $DatePattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:noticeDate, $DatePattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00287][Error] All noticeDate attributes values must be of type Date. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M346"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M346"/>
   <xsl:template match="@*|node()" priority="-2" mode="M346">
      <xsl:apply-templates select="*" mode="M346"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00288-->


	<!--RULE ISM-ID-00288-R1-->
<xsl:template match="*[@ism:noticeReason]" priority="1000" mode="M347">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:noticeReason]"
                       id="ISM-ID-00288-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="string-length(@ism:noticeReason) &lt;= 2048"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(@ism:noticeReason) &lt;= 2048">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00288][Error] All noticeReason attributes must be a string with less than 2048 characters. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M347"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M347"/>
   <xsl:template match="@*|node()" priority="-2" mode="M347">
      <xsl:apply-templates select="*" mode="M347"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00289-->


	<!--RULE ISM-ID-00289-R1-->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M348">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:noticeType]"
                       id="ISM-ID-00289-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:noticeType, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:noticeType, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00289][Error] All noticeType attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M348"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M348"/>
   <xsl:template match="@*|node()" priority="-2" mode="M348">
      <xsl:apply-templates select="*" mode="M348"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00290-->


	<!--RULE ISM-ID-00290-R1-->
<xsl:template match="*[@ism:externalNotice]" priority="1000" mode="M349">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:externalNotice]"
                       id="ISM-ID-00290-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:externalNotice, $BooleanPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:externalNotice, $BooleanPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00290][Error] All externalNotice attributes values must be of type Boolean. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M349"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M349"/>
   <xsl:template match="@*|node()" priority="-2" mode="M349">
      <xsl:apply-templates select="*" mode="M349"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00291-->


	<!--RULE ISM-ID-00291-R1-->
<xsl:template match="*[@ism:ownerProducer]" priority="1000" mode="M350">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:ownerProducer]"
                       id="ISM-ID-00291-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:ownerProducer, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:ownerProducer, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00291][Error] All ownerProducer attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M350"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M350"/>
   <xsl:template match="@*|node()" priority="-2" mode="M350">
      <xsl:apply-templates select="*" mode="M350"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00292-->


	<!--RULE ISM-ID-00292-R1-->
<xsl:template match="*[@ism:pocType]" priority="1000" mode="M351">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:pocType]"
                       id="ISM-ID-00292-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:pocType, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:pocType, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00292][Error] All pocType attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M351"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M351"/>
   <xsl:template match="@*|node()" priority="-2" mode="M351">
      <xsl:apply-templates select="*" mode="M351"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00293-->


	<!--RULE ISM-ID-00293-R1-->
<xsl:template match="*[@ism:releasableTo]" priority="1000" mode="M352">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:releasableTo]"
                       id="ISM-ID-00293-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:releasableTo, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:releasableTo, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00293][Error] All releasableTo attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M352"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M352"/>
   <xsl:template match="@*|node()" priority="-2" mode="M352">
      <xsl:apply-templates select="*" mode="M352"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00294-->


	<!--RULE ISM-ID-00294-R1-->
<xsl:template match="*[@ism:resourceElement]" priority="1000" mode="M353">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:resourceElement]"
                       id="ISM-ID-00294-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:resourceElement, $BooleanPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:resourceElement, $BooleanPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
		    	[ISM-ID-00294][Error] All resourceElement attributes values must be of type Boolean. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M353"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M353"/>
   <xsl:template match="@*|node()" priority="-2" mode="M353">
      <xsl:apply-templates select="*" mode="M353"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00295-->


	<!--RULE ISM-ID-00295-R1-->
<xsl:template match="*[@ism:SARIdentifier]" priority="1000" mode="M354">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:SARIdentifier]"
                       id="ISM-ID-00295-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:SARIdentifier, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:SARIdentifier, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00295][Error] All SARIdentifier attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M354"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M354"/>
   <xsl:template match="@*|node()" priority="-2" mode="M354">
      <xsl:apply-templates select="*" mode="M354"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00296-->


	<!--RULE ISM-ID-00296-R1-->
<xsl:template match="*[@ism:SCIcontrols]" priority="1000" mode="M355">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:SCIcontrols]"
                       id="ISM-ID-00296-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:SCIcontrols, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:SCIcontrols, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00296][Error] All SCIcontrols attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M355"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M355"/>
   <xsl:template match="@*|node()" priority="-2" mode="M355">
      <xsl:apply-templates select="*" mode="M355"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00297-->


	<!--RULE ISM-ID-00297-R1-->
<xsl:template match="*[@ism:unregisteredNoticeType]" priority="1000" mode="M356">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:unregisteredNoticeType]"
                       id="ISM-ID-00297-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="string-length(@ism:unregisteredNoticeType) &lt;= 2048"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="string-length(@ism:unregisteredNoticeType) &lt;= 2048">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00297][Error] All unregisteredNoticeType attributes must be a string with less than 2048 characters. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M356"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M356"/>
   <xsl:template match="@*|node()" priority="-2" mode="M356">
      <xsl:apply-templates select="*" mode="M356"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00298-->


	<!--RULE AttributeContributesToRollupWithException-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and not(some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('RD', 'FRD'))                       )                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('TFNI'))                       )]"
                 priority="1000"
                 mode="M357">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                       and not(some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('RD', 'FRD'))                       )                       and (                         some $ele in $partTags satisfies                           util:containsAnyOfTheTokens($ele/@ism:atomicEnergyMarkings, ('TFNI'))                       )]"
                       id="AttributeContributesToRollupWithException-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('TFNI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('TFNI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00298][Error] USA documents having Transclassified Foreign Nuclear Information (TFNI)     and not having Restricted Data (RD) or Formerly Restricted Data (FRD) must have TFNI at the resource level.'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M357"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M357"/>
   <xsl:template match="@*|node()" priority="-2" mode="M357">
      <xsl:apply-templates select="*" mode="M357"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00299-->


	<!--RULE ISM-ID-00299-R1-->
<xsl:template match="*[util:containsAnyTokenMatching(@ism:declassException, ('AEA'))]"
                 priority="1000"
                 mode="M358">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[util:containsAnyTokenMatching(@ism:declassException, ('AEA'))]"
                       id="ISM-ID-00299-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:atomicEnergyMarkings"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:atomicEnergyMarkings">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00299][Error] If an element contains the attribute declassException with a value of [AEA], 
			it must also contain the attribute atomicEnergyMarkings.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M358"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M358"/>
   <xsl:template match="@*|node()" priority="-2" mode="M358">
      <xsl:apply-templates select="*" mode="M358"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00302-->


	<!--RULE ISM-ID-00302-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                       and util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC-USGOV'))]"
                 priority="1000"
                 mode="M359">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                       and util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC-USGOV'))]"
                       id="ISM-ID-00302-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00302][Error] If ISM_USGOV_RESOURCE and attribute 
            disseminationControls contains the name token [OC-USGOV], then 
            name token [OC] must be specified.
            
            Human Readable: A USA document with OC-USGOV dissemination must 
            also contain an OC dissemination.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M359"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M359"/>
   <xsl:template match="@*|node()" priority="-2" mode="M359">
      <xsl:apply-templates select="*" mode="M359"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00303-->


	<!--RULE ISM-ID-00303-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                             and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                             and util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC-USGOV'))]"
                 priority="1000"
                 mode="M360">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                             and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                             and util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC-USGOV'))]"
                       id="ISM-ID-00303-R1"/>
      <xsl:variable name="portionsWithOC"
                    select="             for $portion in $partTags return             if($portion[util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC'))])             then $portion             else null             "/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $portionWithOC in $portionsWithOC             satisfies $portionWithOC[util:containsAnyOfTheTokens(@ism:disseminationControls, 'OC-USGOV')]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $portionWithOC in $portionsWithOC satisfies $portionWithOC[util:containsAnyOfTheTokens(@ism:disseminationControls, 'OC-USGOV')]">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00303][Error] If ISM_USGOV_RESOURCE and the document contains attribute 
            disseminationControls with name token [OC-USGOV] in the banner, then 
            all [OC] portions must also contain [OC-USGOV].
            
            Human Readable: A USA document with OC-USGOV dissemination in the banner
            must also contain OC-USGOV in any OC portions.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M360"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M360"/>
   <xsl:template match="@*|node()" priority="-2" mode="M360">
      <xsl:apply-templates select="*" mode="M360"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00304-->


	<!--RULE ISM-ID-00304-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-BLFH'))]"
                 priority="1000"
                 mode="M361">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-BLFH'))]"
                       id="ISM-ID-00304-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00304][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [TK-BLFH],
          then it must also contain the name token [TK].
          
          Human Readable: A USA document that contains TALENT KEYHOLE (TK) -BLUEFISH compartment data must also specify that 
          it contains TK data. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M361"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M361"/>
   <xsl:template match="@*|node()" priority="-2" mode="M361">
      <xsl:apply-templates select="*" mode="M361"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00305-->


	<!--RULE ISM-ID-00305-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE     and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-IDIT'))]"
                 priority="1000"
                 mode="M362">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE     and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-IDIT'))]"
                       id="ISM-ID-00305-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00305][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [TK-IDIT],
      then it must also contain the name token [TK].
      
      Human Readable: A USA document that contains TALENT KEYHOLE (TK) -IDITAROD compartment data must also specify that 
      it contains TK data. 
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M362"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M362"/>
   <xsl:template match="@*|node()" priority="-2" mode="M362">
      <xsl:apply-templates select="*" mode="M362"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00306-->


	<!--RULE ISM-ID-00306-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE     and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-KAND'))]"
                 priority="1000"
                 mode="M363">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE     and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-KAND'))]"
                       id="ISM-ID-00306-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00306][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [TK-KAND],
      then it must also contain the name token [TK].
      
      Human Readable: A USA document that contains TALENT KEYHOLE (TK) -KANDIK compartment data must also specify that 
      it contains TK data. 
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M363"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M363"/>
   <xsl:template match="@*|node()" priority="-2" mode="M363">
      <xsl:apply-templates select="*" mode="M363"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00307-->


	<!--RULE ISM-ID-00307-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^TK-BLFH-[A-Z]{1,6}$'))]"
                 priority="1000"
                 mode="M364">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^TK-BLFH-[A-Z]{1,6}$'))]"
                       id="ISM-ID-00307-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-BLFH'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-BLFH'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00307][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains a token matching [TK-BLFH-XXXXXX],
            where X is represented by the regular expression character class [A-Z]{1,6}, then it must also contain the
            name token [TK-BLFH].
            
            Human Readable: A USA document that contains TALENT KEYHOLE (TK) BLUEFISH sub-compartments must
            also specify that it contains TK -BLUEFISH compartment data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M364"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M364"/>
   <xsl:template match="@*|node()" priority="-2" mode="M364">
      <xsl:apply-templates select="*" mode="M364"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00308-->


	<!--RULE ISM-ID-00308-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^TK-IDIT-[A-Z]{1,6}$'))]"
                 priority="1000"
                 mode="M365">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^TK-IDIT-[A-Z]{1,6}$'))]"
                       id="ISM-ID-00308-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-IDIT'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-IDIT'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00308][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains a token matching [TK-IDIT-XXXXXX],
            where X is represented by the regular expression character class [A-Z]{1,6}, then it must also contain the
            name token [TK-IDIT].
            
            Human Readable: A USA document that contains TALENT KEYHOLE (TK) IDITAROD sub-compartments must
            also specify that it contains TK -IDITAROD compartment data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M365"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M365"/>
   <xsl:template match="@*|node()" priority="-2" mode="M365">
      <xsl:apply-templates select="*" mode="M365"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00309-->


	<!--RULE ISM-ID-00309-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^TK-KAND-[A-Z]{1,6}$'))]"
                 priority="1000"
                 mode="M366">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^TK-KAND-[A-Z]{1,6}$'))]"
                       id="ISM-ID-00309-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-KAND'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-KAND'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00309][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains a token matching [TK-KAND-XXXXXX],
            where X is represented by the regular expression character class [A-Z]{1,6}, then it must also contain the
            name token [TK-KAND].
            
            Human Readable: A USA document that contains TALENT KEYHOLE (TK) KANDIK sub-compartments must
            also specify that it contains TK -KANDIK compartment data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M366"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M366"/>
   <xsl:template match="@*|node()" priority="-2" mode="M366">
      <xsl:apply-templates select="*" mode="M366"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00310-->


	<!--RULE ISM-ID-00310-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE     and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-EU'))]"
                 priority="1000"
                 mode="M367">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE     and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-EU'))]"
                       id="ISM-ID-00310-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00310][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [SI-EU],
      then it must also contain the name token [SI].
      
      Human Readable: A USA document that contains ENDSEAL (SI) -ECRU compartment data must also specify that 
      it contains SI data. 
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M367"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M367"/>
   <xsl:template match="@*|node()" priority="-2" mode="M367">
      <xsl:apply-templates select="*" mode="M367"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00311-->


	<!--RULE ISM-ID-00311-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-NK'))]"
                 priority="1000"
                 mode="M368">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-NK'))]"
                       id="ISM-ID-00311-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00311][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [SI-NK],
            then it must also contain the name token [SI].
            
            Human Readable: A USA document that contains ENDSEAL (SI) -NONBOOK compartment data must also specify that 
            it contains SI data. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M368"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M368"/>
   <xsl:template match="@*|node()" priority="-2" mode="M368">
      <xsl:apply-templates select="*" mode="M368"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00313-->


	<!--RULE ISM-ID-00313-R1-->
<xsl:template match="*[util:containsAnyOfTheTokens(@ism:nonICmarkings, ('ND'))]"
                 priority="1000"
                 mode="M369">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[util:containsAnyOfTheTokens(@ism:nonICmarkings, ('ND'))]"
                       id="ISM-ID-00313-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00313][Error] If nonICmarkings contains the token [ND] then the 
            attribute disseminationControls must contain [NF].
            
            Human Readable: NODIS data must be marked NOFORN.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M369"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M369"/>
   <xsl:template match="@*|node()" priority="-2" mode="M369">
      <xsl:apply-templates select="*" mode="M369"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00314-->


	<!--RULE ISM-ID-00314-R1-->
<xsl:template match="*[util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD'))]"
                 priority="1000"
                 mode="M370">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD'))]"
                       id="ISM-ID-00314-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00314][Error] If nonICmarkings contains the token [XD] then the 
            attribute disseminationControls must contain [NF].
            
            Human Readable: EXDIS data must be marked NOFORN.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M370"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M370"/>
   <xsl:template match="@*|node()" priority="-2" mode="M370">
      <xsl:apply-templates select="*" mode="M370"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00315-->


	<!--RULE ISM-ID-00315-R1-->
<xsl:template match="             *[not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))             and util:contributesToRollup(.)             and $ISM_USGOV_RESOURCE             and not(@ism:classification = 'U')             and util:containsAnyTokenMatching(@ism:ownerProducer, ('NATO:?'))]"
                 priority="1000"
                 mode="M371">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="             *[not(generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT))             and util:contributesToRollup(.)             and $ISM_USGOV_RESOURCE             and not(@ism:classification = 'U')             and util:containsAnyTokenMatching(@ism:ownerProducer, ('NATO:?'))]"
                       id="ISM-ID-00315-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:declassException, ('NATO', 'NATO-AEA'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens($ISM_RESOURCE_ELEMENT/@ism:declassException, ('NATO', 'NATO-AEA'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [ISM-ID-00315][Error] If element meets ISM_CONTRIBUTES and attribute
            ownerProducer contains the token [NATO], then attribute declassException must be
            specified with a value of [NATO] or [NATO-AEA] on the resourceElement. Human Readable:
            Any non-resource classified element that contributes to the document's banner roll-up
            and has NATO Information) must also specify a NATO declass exemption on the banner.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M371"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M371"/>
   <xsl:template match="@*|node()" priority="-2" mode="M371">
      <xsl:apply-templates select="*" mode="M371"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00316-->


	<!--RULE ISM-ID-00316-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                                                 and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                                                 and util:containsAnyOfTheTokens(@ism:declassException, ('NATO'))]"
                 priority="1000"
                 mode="M372">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                                                 and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                                                 and util:containsAnyOfTheTokens(@ism:declassException, ('NATO'))]"
                       id="ISM-ID-00316-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyTokenMatching(string-join($partOwnerProducer_tok,' '), ('^NATO:?'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyTokenMatching(string-join($partOwnerProducer_tok,' '), ('^NATO:?'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00316][Error] USA documents marked with a NATO declass exemption must have NATO portions.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M372"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M372"/>
   <xsl:template match="@*|node()" priority="-2" mode="M372">
      <xsl:apply-templates select="*" mode="M372"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00317-->


	<!--RULE ISM-ID-00317-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:declassException, ('NATO-AEA'))]"
                 priority="1000"
                 mode="M373">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)                         and util:containsAnyOfTheTokens(@ism:declassException, ('NATO-AEA'))]"
                       id="ISM-ID-00317-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyTokenMatching(string-join($partOwnerProducer_tok, ' '), ('NATO:?'))                           and count($partAtomicEnergyMarkings_tok)&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyTokenMatching(string-join($partOwnerProducer_tok, ' '), ('NATO:?')) and count($partAtomicEnergyMarkings_tok)&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00317][Error] USA documents marked with a NATO-AEA declass exemption must have at least one NATO portion 
            and one portion that contains Atomic Energy Markings.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M373"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M373"/>
   <xsl:template match="@*|node()" priority="-2" mode="M373">
      <xsl:apply-templates select="*" mode="M373"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00318-->


	<!--RULE CheckCommonCountries-R1-->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and @ism:*[local-name() = 'releasableTo']]"
                 priority="1000"
                 mode="M374">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and @ism:*[local-name() = 'releasableTo']]"
                       id="CheckCommonCountries-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count($relToCalculatedBannerTokens) != 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count($relToCalculatedBannerTokens) != 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00318'"/>
                  <xsl:text/>][Error] The banner cannot have @ism:<xsl:text/>
                  <xsl:value-of select="'releasableTo'"/>
                  <xsl:text/> because
      there is no common country in the contributing portions.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="if(count($relToCalculatedBannerTokens) != 0 and @ism:compilationReason[normalize-space(.)])        then util:isSubsetOf($relToActualBannerTokens, $relToCalculatedBannerTokens) else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(count($relToCalculatedBannerTokens) != 0 and @ism:compilationReason[normalize-space(.)]) then util:isSubsetOf($relToActualBannerTokens, $relToCalculatedBannerTokens) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00318'"/>
                  <xsl:text/>][Error] The banner @ism:<xsl:text/>
                  <xsl:value-of select="'releasableTo'"/>
                  <xsl:text/> must be a subset of the 
      common countries for contributing portions because @ism:compilationReason is specified. Common countries: [<xsl:text/>
                  <xsl:value-of select="util:join($relToCalculatedBannerTokens)"/>
                  <xsl:text/>].
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="if(count($relToCalculatedBannerTokens) != 0 and not(@ism:compilationReason[normalize-space(.)]))        then util:join(util:sort($relToCalculatedBannerTokens)) = util:join(util:sort($relToActualBannerTokens)) else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(count($relToCalculatedBannerTokens) != 0 and not(@ism:compilationReason[normalize-space(.)])) then util:join(util:sort($relToCalculatedBannerTokens)) = util:join(util:sort($relToActualBannerTokens)) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00318'"/>
                  <xsl:text/>][Error] The banner @ism:<xsl:text/>
                  <xsl:value-of select="'releasableTo'"/>
                  <xsl:text/> must match the set of the common countries for 
      contributing portions because @ism:compilationReason is not specified. Common countries: [<xsl:text/>
                  <xsl:value-of select="util:join($relToCalculatedBannerTokens)"/>
                  <xsl:text/>].
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M374"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M374"/>
   <xsl:template match="@*|node()" priority="-2" mode="M374">
      <xsl:apply-templates select="*" mode="M374"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00319-->


	<!--RULE ISM-ID-00319-R1-->
<xsl:template match="*[util:containsAnyTokenMatching(@ism:ownerProducer, 'USA') and @ism:releasableTo and $ISM_USGOV_RESOURCE]"
                 priority="1000"
                 mode="M375">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[util:containsAnyTokenMatching(@ism:ownerProducer, 'USA') and @ism:releasableTo and $ISM_USGOV_RESOURCE]"
                       id="ISM-ID-00319-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count(tokenize(normalize-space(string(@ism:releasableTo)), ' ')) &gt; 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count(tokenize(normalize-space(string(@ism:releasableTo)), ' ')) &gt; 1">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ISM-ID-00319][Error] If ISM_USGOV_RESOURCE and ownerProducer contains 'USA' and attribute
            releasableTo is specified, then releasableTo must contain more than a single
            token.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M375"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M375"/>
   <xsl:template match="@*|node()" priority="-2" mode="M375">
      <xsl:apply-templates select="*" mode="M375"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00320-->


	<!--RULE CheckCommonCountries-R1-->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and @ism:*[local-name() = 'displayOnlyTo']]"
                 priority="1000"
                 mode="M376">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and @ism:*[local-name() = 'displayOnlyTo']]"
                       id="CheckCommonCountries-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count($displayToCalculatedBannerTokens) != 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count($displayToCalculatedBannerTokens) != 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00320'"/>
                  <xsl:text/>][Error] The banner cannot have @ism:<xsl:text/>
                  <xsl:value-of select="'displayOnlyTo'"/>
                  <xsl:text/> because
      there is no common country in the contributing portions.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="if(count($displayToCalculatedBannerTokens) != 0 and @ism:compilationReason[normalize-space(.)])        then util:isSubsetOf($displayToActualBannerTokens, $displayToCalculatedBannerTokens) else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(count($displayToCalculatedBannerTokens) != 0 and @ism:compilationReason[normalize-space(.)]) then util:isSubsetOf($displayToActualBannerTokens, $displayToCalculatedBannerTokens) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00320'"/>
                  <xsl:text/>][Error] The banner @ism:<xsl:text/>
                  <xsl:value-of select="'displayOnlyTo'"/>
                  <xsl:text/> must be a subset of the 
      common countries for contributing portions because @ism:compilationReason is specified. Common countries: [<xsl:text/>
                  <xsl:value-of select="util:join($displayToCalculatedBannerTokens)"/>
                  <xsl:text/>].
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="if(count($displayToCalculatedBannerTokens) != 0 and not(@ism:compilationReason[normalize-space(.)]))        then util:join(util:sort($displayToCalculatedBannerTokens)) = util:join(util:sort($displayToActualBannerTokens)) else true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="if(count($displayToCalculatedBannerTokens) != 0 and not(@ism:compilationReason[normalize-space(.)])) then util:join(util:sort($displayToCalculatedBannerTokens)) = util:join(util:sort($displayToActualBannerTokens)) else true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00320'"/>
                  <xsl:text/>][Error] The banner @ism:<xsl:text/>
                  <xsl:value-of select="'displayOnlyTo'"/>
                  <xsl:text/> must match the set of the common countries for 
      contributing portions because @ism:compilationReason is not specified. Common countries: [<xsl:text/>
                  <xsl:value-of select="util:join($displayToCalculatedBannerTokens)"/>
                  <xsl:text/>].
    </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M376"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M376"/>
   <xsl:template match="@*|node()" priority="-2" mode="M376">
      <xsl:apply-templates select="*" mode="M376"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00321-->


	<!--RULE MutuallyExclusiveAttributeValues-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE         and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD', 'FRD', 'TFNI'))]"
                 priority="1000"
                 mode="M377">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE         and util:containsAnyOfTheTokens(@ism:atomicEnergyMarkings, ('RD', 'FRD', 'TFNI'))]"
                       id="MutuallyExclusiveAttributeValues-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( for $token in tokenize(normalize-space(string(@ism:atomicEnergyMarkings)),' ') return  if($token = ('RD', 'FRD', 'TFNI')) then 1 else null ) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( for $token in tokenize(normalize-space(string(@ism:atomicEnergyMarkings)),' ') return if($token = ('RD', 'FRD', 'TFNI')) then 1 else null ) = 1">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'         [ISM-ID-00321][Error] If ISM_USGOV_RESOURCE, then tokens [RD],                [FRD] and [TFNI] are mutually exclusive for attribute atomicEnergyMarkings.         Human Readable: RD, FRD and TFNI are mutually exclusive and cannot be commingled         in a portion mark or in the banner line.         '"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M377"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M377"/>
   <xsl:template match="@*|node()" priority="-2" mode="M377">
      <xsl:apply-templates select="*" mode="M377"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00324-->


	<!--RULE ISM-ID-00324-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)         and not(@ism:classification='U' and util:isUncaveatedAndNoFDR(.))         and not(@ism:compilationReason)]"
                 priority="1000"
                 mode="M378">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)         and not(@ism:classification='U' and util:isUncaveatedAndNoFDR(.))         and not(@ism:compilationReason)]"
                       id="ISM-ID-00324-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count($partTags) &gt; 0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($partTags) &gt; 0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ISM-ID-00324][Error] If a document is ISM_USGOV_RESOURCE, it must
            contain portion markings. 
            
            Human Readable: All valid ISM_USGOV_RESOURCE documents must
            also contain portion markings. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M378"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M378"/>
   <xsl:template match="@*|node()" priority="-2" mode="M378">
      <xsl:apply-templates select="*" mode="M378"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00325-->


	<!--RULE MutuallyExclusiveAttributeValues-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                                    and util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC', 'RELIDO'))]"
                 priority="1000"
                 mode="M379">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                                    and util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC', 'RELIDO'))]"
                       id="MutuallyExclusiveAttributeValues-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( for $token in tokenize(normalize-space(string(@ism:disseminationControls)),' ') return  if($token = ('OC', 'RELIDO')) then 1 else null ) = 1"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( for $token in tokenize(normalize-space(string(@ism:disseminationControls)),' ') return if($token = ('OC', 'RELIDO')) then 1 else null ) = 1">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			               <xsl:text/>
                  <xsl:value-of select="'   [ISM-ID-00325][Error] If ISM_USGOV_RESOURCE, then tokens [OC]    and [RELIDO] are mutually exclusive for attribute disseminationControls.   '"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M379"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M379"/>
   <xsl:template match="@*|node()" priority="-2" mode="M379">
      <xsl:apply-templates select="*" mode="M379"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00326-->


	<!--RULE ISM-ID-00326-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE              and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)         and util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC'))]"
                 priority="1000"
                 mode="M380">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE              and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)         and util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC'))]"
                       id="ISM-ID-00326-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="/*//ntk:AccessPolicy[.='urn:us:gov:ic:aces:ntk:oc']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="/*//ntk:AccessPolicy[.='urn:us:gov:ic:aces:ntk:oc']">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ISM-ID-00326][Error] ORCON
         information (i.e. @ism:disseminationControls of the resource node contains [OC]) requires ORCON profile NTK
         metadata.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M380"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M380"/>
   <xsl:template match="@*|node()" priority="-2" mode="M380">
      <xsl:apply-templates select="*" mode="M380"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00327-->


	<!--RULE ISM-ID-00327-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE         and util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))         and util:containsAnyOfTheTokens(@ism:classification, ('U'))]"
                 priority="1000"
                 mode="M381">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE         and util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))         and util:containsAnyOfTheTokens(@ism:classification, ('U'))]"
                       id="ISM-ID-00327-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsOnlyTheTokens(@ism:disseminationControls, ('REL', 'RELIDO', 'NF', 'EYES', 'DISPLAYONLY', 'FOUO'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsOnlyTheTokens(@ism:disseminationControls, ('REL', 'RELIDO', 'NF', 'EYES', 'DISPLAYONLY', 'FOUO'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00327][Error] Dissemination control markings, excluding Foreign Disclosure and Release markings 
            (REL, RELIDO, NF, DISPLAYONLY, or EYES), in elements of USA Unclassified documents supersede and take precedence 
            over FOUO.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M381"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M381"/>
   <xsl:template match="@*|node()" priority="-2" mode="M381">
      <xsl:apply-templates select="*" mode="M381"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00328-->


	<!--RULE ISM-ID-00328-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))                         and util:containsAnyOfTheTokens(@ism:classification, ('U'))]"
                 priority="1000"
                 mode="M382">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:disseminationControls, ('FOUO'))                         and util:containsAnyOfTheTokens(@ism:classification, ('U'))]"
                       id="ISM-ID-00328-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(@ism:nonICmarkings)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@ism:nonICmarkings)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00328][Error] Non-IC dissemination control markings in elements of USA Unclassified documents 
            supersede and take precedence over FOUO.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M382"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M382"/>
   <xsl:template match="@*|node()" priority="-2" mode="M382">
      <xsl:apply-templates select="*" mode="M382"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00329-->


	<!--RULE ISM-ID-00329-R1-->
<xsl:template match="*[@ism:declassDate and @ism:declassEvent]"
                 priority="1000"
                 mode="M383">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:declassDate and @ism:declassEvent]"
                       id="ISM-ID-00329-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="false()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="false()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
	       [ISM-ID-00329][Error] Attributes declassEvent and declassDate 
	       are mutually exclusive.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M383"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M383"/>
   <xsl:template match="@*|node()" priority="-2" mode="M383">
      <xsl:apply-templates select="*" mode="M383"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00330-->


	<!--RULE ISM-ID-00330-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                       and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS-P'))]"
                 priority="1000"
                 mode="M384">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                       and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS-P'))]"
                       id="ISM-ID-00330-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00330][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [HCS-P], then attribute 
            classification must have a value of [TS], or [S].
            
            Human Readable: A USA document with HCS-PRODUCT compartment data must be classified SECRET or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M384"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M384"/>
   <xsl:template match="@*|node()" priority="-2" mode="M384">
      <xsl:apply-templates select="*" mode="M384"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00331-->


	<!--RULE ISM-ID-00331-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^HCS-P-[A-Z0-9]{1,6}$'))]"
                 priority="1000"
                 mode="M385">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^HCS-P-[A-Z0-9]{1,6}$'))]"
                       id="ISM-ID-00331-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS-P'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS-P'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
          [ISM-ID-00331][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains a token matching [HCS-P-XXXXXX],
          where X is represented by the regular expression character class [A-Z0-9]{1,6}, then it must also contain the
          name token [HCS-P].
          
          Human Readable: A USA document with HCS-PRODUCT sub-compartment data must also specify that it contains
          HCS-PRODUCT compartment data.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M385"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M385"/>
   <xsl:template match="@*|node()" priority="-2" mode="M385">
      <xsl:apply-templates select="*" mode="M385"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00332-->


	<!--RULE ISM-ID-00332-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS-O'))]"
                 priority="1000"
                 mode="M386">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS-O'))]"
                       id="ISM-ID-00332-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:classification, ('TS', 'S'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00332][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [HCS-O], then attribute 
            classification must have a value of [TS] or [S].
            
            Human Readable: A USA document with HCS-OPERATIONS compartment data must be classified SECRET or TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M386"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M386"/>
   <xsl:template match="@*|node()" priority="-2" mode="M386">
      <xsl:apply-templates select="*" mode="M386"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00333-->


	<!--RULE ISM-ID-00333-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^HCS-[A-Z]$'))]"
                 priority="1000"
                 mode="M387">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^HCS-[A-Z]$'))]"
                       id="ISM-ID-00333-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
      [ISM-ID-00333][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains a token
      matching [HCS-X], where X is represented by the regular expression character class [A-Z], then
      it must also contain the name token [HCS]. Human Readable: A USA document with HCS compartment
      data must also specify that it contains HCS data. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M387"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M387"/>
   <xsl:template match="@*|node()" priority="-2" mode="M387">
      <xsl:apply-templates select="*" mode="M387"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00335-->


	<!--RULE ISM-ID-00335-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS-O'))]"
                 priority="1000"
                 mode="M388">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS-O'))]"
                       id="ISM-ID-00335-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00335][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [HCS-O],
            then attribute disseminationControls must contain the name token [OC].
            
            Human Readable: A USA document with HCS-OPERATIONS data must be marked for 
            ORIGINATOR CONTROLLED dissemination.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M388"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M388"/>
   <xsl:template match="@*|node()" priority="-2" mode="M388">
      <xsl:apply-templates select="*" mode="M388"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00336-->


	<!--RULE ISM-ID-00336-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^HCS-P-[A-Z0-9]{1,6}$'))]"
                 priority="1000"
                 mode="M389">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyTokenMatching(@ism:SCIcontrols, ('^HCS-P-[A-Z0-9]{1,6}$'))]"
                       id="ISM-ID-00336-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00336][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols contains the name token [HCS-P-XXXXXX], 
            where X is represented by the regular expression character class [A-Z0-9]{1,6},
            then attribute disseminationControls must contain the name token [OC].
            
            Human Readable: A USA document with HCS-PRODUCT sub-compartments must be marked for 
            ORIGINATOR CONTROLLED dissemination.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M389"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M389"/>
   <xsl:template match="@*|node()" priority="-2" mode="M389">
      <xsl:apply-templates select="*" mode="M389"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00341-->


	<!--RULE ISM-ID-00341-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and (util:containsAnyTokenMatching(@ism:SCIcontrols, ('^SI-G-[A-Z]{4}$'))) or util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-G'))]"
                 priority="1000"
                 mode="M390">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and (util:containsAnyTokenMatching(@ism:SCIcontrols, ('^SI-G-[A-Z]{4}$'))) or util:containsAnyOfTheTokens(@ism:SCIcontrols, ('SI-G'))]"
                       id="ISM-ID-00341-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC-USGOV')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC-USGOV')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [ISM-ID-00341][Error] If ISM_USGOV_RESOURCE and SCIcontrols contains a token matching [SI-G] or
            [SI-G-XXXX], then ism:disseminationControls cannot contain [OC-USGOV] Human Readable:
            OC-GOV cannot be used if SI-G or an SI-G subs are present. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M390"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M390"/>
   <xsl:template match="@*|node()" priority="-2" mode="M390">
      <xsl:apply-templates select="*" mode="M390"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00343-->


	<!--RULE ISM-ID-00343-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and         count($partSCIcontrols_tok)&gt;0]"
                 priority="1000"
                 mode="M391">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and         count($partSCIcontrols_tok)&gt;0]"
                       id="ISM-ID-00343-R1"/>
      <xsl:variable name="missingSCI"
                    select="for $token in distinct-values($partSCIcontrols) return                                         if (index-of(tokenize(@ism:SCIcontrols,' '), $token) &gt; 0 )                                         then null else $token"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count($missingSCI)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($missingSCI)=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00343][Error] All SCI controls specified in the document that contribute to rollup must
            be rolled up to the resource level. The following tokens were found to be missing from the resource
            element: <xsl:text/>
                  <xsl:value-of select="string-join($missingSCI, ', ')"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M391"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M391"/>
   <xsl:template match="@*|node()" priority="-2" mode="M391">
      <xsl:apply-templates select="*" mode="M391"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00344-->


	<!--RULE ISM-ID-00344-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)         and @ism:SCIcontrols         and string-length(normalize-space(@ism:compilationReason)) = 0]"
                 priority="1000"
                 mode="M392">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)         and @ism:SCIcontrols         and string-length(normalize-space(@ism:compilationReason)) = 0]"
                       id="ISM-ID-00344-R1"/>
      <xsl:variable name="missingSCI"
                    select="for $token in tokenize(@ism:SCIcontrols, ' ') return             if (index-of(distinct-values($partSCIcontrols), $token) &gt; 0)             then null else $token"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count($missingSCI)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($missingSCI)=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00344][Error] All SCI controls specified at the resource level must be found in a contributing
            portion of the document unless there is a compilation reason of the exception. The following tokens 
            were found to be missing from the portions: <xsl:text/>
                  <xsl:value-of select="string-join($missingSCI, ', ')"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M392"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M392"/>
   <xsl:template match="@*|node()" priority="-2" mode="M392">
      <xsl:apply-templates select="*" mode="M392"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00345-->


	<!--RULE ISM-ID-00345-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:disseminationControls, ('EYES'))]"
                 priority="1000"
                 mode="M393">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:disseminationControls, ('EYES'))]"
                       id="ISM-ID-00345-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsOnlyTheTokens(@ism:releasableTo, ('USA', 'AUS','CAN','GBR', 'NZL'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsOnlyTheTokens(@ism:releasableTo, ('USA', 'AUS','CAN','GBR', 'NZL'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00345][Error] If attribute disseminationControls contains the value [EYES], 
			the attribute releasableTo must only contain the values of [USA], [AUS], [CAN], [GBR] or [NZL].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M393"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M393"/>
   <xsl:template match="@*|node()" priority="-2" mode="M393">
      <xsl:apply-templates select="*" mode="M393"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00346-->


	<!--RULE ISM-ID-00346-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('DS'))]"
                 priority="1000"
                 mode="M394">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('DS'))]"
                       id="ISM-ID-00346-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:classification='U'"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:classification='U'">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00346][Error] If ISM_USGOV_RESOURCE and attribute 
			nonICmarkings contains the name token [DS], then attribute
			classification must have a value of [U].
			
			Human Readable: Portions marked DS (LIMDIS) as a nonICmarkings in a USA document
			must be classified UNCLASSIFIED.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M394"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M394"/>
   <xsl:template match="@*|node()" priority="-2" mode="M394">
      <xsl:apply-templates select="*" mode="M394"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00347-->


	<!--RULE ISM-ID-00347-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and         count($partSARIdentifier_tok)&gt;0]"
                 priority="1000"
                 mode="M395">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and         count($partSARIdentifier_tok)&gt;0]"
                       id="ISM-ID-00347-R1"/>
      <xsl:variable name="missingSAR"
                    select="for $token in distinct-values($partSARIdentifier) return                                         if (index-of(tokenize(@ism:SARIdentifier,' '), $token) &gt; 0 )                                         then null else $token"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count($missingSAR)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($missingSAR)=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00347][Error] All SAR Identifiers specified in the document that contribute to rollup must
            be rolled up to the resource level. The following tokens were found to be missing from the resource
            element: <xsl:text/>
                  <xsl:value-of select="string-join($missingSAR, ', ')"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M395"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M395"/>
   <xsl:template match="@*|node()" priority="-2" mode="M395">
      <xsl:apply-templates select="*" mode="M395"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00348-->


	<!--RULE ISM-ID-00348-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)         and @ism:SARIdentifier         and string-length(normalize-space(@ism:compilationReason)) = 0]"
                 priority="1000"
                 mode="M396">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)         and @ism:SARIdentifier         and string-length(normalize-space(@ism:compilationReason)) = 0]"
                       id="ISM-ID-00348-R1"/>
      <xsl:variable name="missingSAR"
                    select="for $token in tokenize(@ism:SARIdentifier, ' ') return             if (index-of(distinct-values($partSARIdentifier), $token) &gt; 0)             then null else $token"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count($missingSAR)=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="count($missingSAR)=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00348][Error] All SAR Identifiers specified at the resource level must be found in a contributing
            portion of the document unless there is a compilation reason of the exception. The following tokens 
            were found to be missing from the portions: <xsl:text/>
                  <xsl:value-of select="string-join($missingSAR, ', ')"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M396"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M396"/>
   <xsl:template match="@*|node()" priority="-2" mode="M396">
      <xsl:apply-templates select="*" mode="M396"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00349-->


	<!--RULE ISM-ID-00349-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)       and util:containsAnyOfTheTokens(@ism:disseminationControls, ('PR'))]"
                 priority="1000"
                 mode="M397">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)       and util:containsAnyOfTheTokens(@ism:disseminationControls, ('PR'))]"
                       id="ISM-ID-00349-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="/*//ntk:AccessPolicy[starts-with(.,'urn:us:gov:ic:aces:ntk:propin:')]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="/*//ntk:AccessPolicy[starts-with(.,'urn:us:gov:ic:aces:ntk:propin:')]">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ISM-ID-00349][Error] PROPIN information (i.e. @ism:disseminationControls of the resource node contains [PR])
         requires PROPIN NTK metadata.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M397"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M397"/>
   <xsl:template match="@*|node()" priority="-2" mode="M397">
      <xsl:apply-templates select="*" mode="M397"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00350-->


	<!--RULE ISM-ID-00350-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)       and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD'))]"
                 priority="1000"
                 mode="M398">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)       and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('XD'))]"
                       id="ISM-ID-00350-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="/*//ntk:AccessPolicy[.='urn:us:gov:ic:aces:ntk:xd']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="/*//ntk:AccessPolicy[.='urn:us:gov:ic:aces:ntk:xd']">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ISM-ID-00350][Error]
         Exclusive Distribution information (i.e. @ism:nonICmarkings of the resource node contains [XD]) requires XD
         profile NTK metadata.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M398"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M398"/>
   <xsl:template match="@*|node()" priority="-2" mode="M398">
      <xsl:apply-templates select="*" mode="M398"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00351-->


	<!--RULE ISM-ID-00351-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)       and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('ND'))]"
                 priority="1000"
                 mode="M399">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE       and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)       and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('ND'))]"
                       id="ISM-ID-00351-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="/*//ntk:AccessPolicy[.='urn:us:gov:ic:aces:ntk:nd']"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="/*//ntk:AccessPolicy[.='urn:us:gov:ic:aces:ntk:nd']">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[ISM-ID-00351][Error] No
         Distribution information (i.e. @ism:nonICmarkings of the resource node contains [ND]) requires ND profile NTK
         metadata.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M399"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M399"/>
   <xsl:template match="@*|node()" priority="-2" mode="M399">
      <xsl:apply-templates select="*" mode="M399"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00352-->


	<!--RULE NtkHasCorrespondingData-R1-->
<xsl:template match="ntk:Access//ntk:AccessProfile[ntk:AccessPolicy[starts-with(., 'urn:us:gov:ic:aces:ntk:propin:')] and $ISM_USGOV_RESOURCE]"
                 priority="1000"
                 mode="M400">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="ntk:Access//ntk:AccessProfile[ntk:AccessPolicy[starts-with(., 'urn:us:gov:ic:aces:ntk:propin:')] and $ISM_USGOV_RESOURCE]"
                       id="NtkHasCorrespondingData-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="index-of($partDisseminationControls_tok, 'PR')&gt;0 or index-of($bannerDisseminationControls_tok, 'PR')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partDisseminationControls_tok, 'PR')&gt;0 or index-of($bannerDisseminationControls_tok, 'PR')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00352'"/>
                  <xsl:text/>][error] <xsl:text/>
                  <xsl:value-of select="'PROPIN'"/>
                  <xsl:text/> NTK metadata
         requires that <xsl:text/>
                  <xsl:value-of select="'disseminationControls'"/>
                  <xsl:text/> contain <xsl:text/>
                  <xsl:value-of select="'PR'"/>
                  <xsl:text/> in at least one of (a)
         a portion that contributes to roll-up or (b) the banner.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M400"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M400"/>
   <xsl:template match="@*|node()" priority="-2" mode="M400">
      <xsl:apply-templates select="*" mode="M400"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00353-->


	<!--RULE NtkHasCorrespondingData-R1-->
<xsl:template match="ntk:Access//ntk:AccessProfile[ntk:AccessPolicy[starts-with(., 'urn:us:gov:ic:aces:ntk:oc')] and $ISM_USGOV_RESOURCE]"
                 priority="1000"
                 mode="M401">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="ntk:Access//ntk:AccessProfile[ntk:AccessPolicy[starts-with(., 'urn:us:gov:ic:aces:ntk:oc')] and $ISM_USGOV_RESOURCE]"
                       id="NtkHasCorrespondingData-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="index-of($partDisseminationControls_tok, 'OC')&gt;0 or index-of($bannerDisseminationControls_tok, 'OC')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partDisseminationControls_tok, 'OC')&gt;0 or index-of($bannerDisseminationControls_tok, 'OC')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00353'"/>
                  <xsl:text/>][error] <xsl:text/>
                  <xsl:value-of select="'ORCON'"/>
                  <xsl:text/> NTK metadata
         requires that <xsl:text/>
                  <xsl:value-of select="'disseminationControls'"/>
                  <xsl:text/> contain <xsl:text/>
                  <xsl:value-of select="'OC'"/>
                  <xsl:text/> in at least one of (a)
         a portion that contributes to roll-up or (b) the banner.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M401"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M401"/>
   <xsl:template match="@*|node()" priority="-2" mode="M401">
      <xsl:apply-templates select="*" mode="M401"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00354-->


	<!--RULE NtkHasCorrespondingData-R1-->
<xsl:template match="ntk:Access//ntk:AccessProfile[ntk:AccessPolicy[starts-with(., 'urn:us:gov:ic:aces:ntk:xd')] and $ISM_USGOV_RESOURCE]"
                 priority="1000"
                 mode="M402">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="ntk:Access//ntk:AccessProfile[ntk:AccessPolicy[starts-with(., 'urn:us:gov:ic:aces:ntk:xd')] and $ISM_USGOV_RESOURCE]"
                       id="NtkHasCorrespondingData-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="index-of($partNonICmarkings_tok, 'XD')&gt;0 or index-of($bannerNonICmarkings_tok, 'XD')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partNonICmarkings_tok, 'XD')&gt;0 or index-of($bannerNonICmarkings_tok, 'XD')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00354'"/>
                  <xsl:text/>][error] <xsl:text/>
                  <xsl:value-of select="'EXDIS'"/>
                  <xsl:text/> NTK metadata
         requires that <xsl:text/>
                  <xsl:value-of select="'nonICmarkings'"/>
                  <xsl:text/> contain <xsl:text/>
                  <xsl:value-of select="'XD'"/>
                  <xsl:text/> in at least one of (a)
         a portion that contributes to roll-up or (b) the banner.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M402"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M402"/>
   <xsl:template match="@*|node()" priority="-2" mode="M402">
      <xsl:apply-templates select="*" mode="M402"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00355-->


	<!--RULE NtkHasCorrespondingData-R1-->
<xsl:template match="ntk:Access//ntk:AccessProfile[ntk:AccessPolicy[starts-with(., 'urn:us:gov:ic:aces:ntk:nd')] and $ISM_USGOV_RESOURCE]"
                 priority="1000"
                 mode="M403">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="ntk:Access//ntk:AccessProfile[ntk:AccessPolicy[starts-with(., 'urn:us:gov:ic:aces:ntk:nd')] and $ISM_USGOV_RESOURCE]"
                       id="NtkHasCorrespondingData-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="index-of($partNonICmarkings_tok, 'ND')&gt;0 or index-of($bannerNonICmarkings_tok, 'ND')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partNonICmarkings_tok, 'ND')&gt;0 or index-of($bannerNonICmarkings_tok, 'ND')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00355'"/>
                  <xsl:text/>][error] <xsl:text/>
                  <xsl:value-of select="'NODIS'"/>
                  <xsl:text/> NTK metadata
         requires that <xsl:text/>
                  <xsl:value-of select="'nonICmarkings'"/>
                  <xsl:text/> contain <xsl:text/>
                  <xsl:value-of select="'ND'"/>
                  <xsl:text/> in at least one of (a)
         a portion that contributes to roll-up or (b) the banner.</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M403"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M403"/>
   <xsl:template match="@*|node()" priority="-2" mode="M403">
      <xsl:apply-templates select="*" mode="M403"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00356-->


	<!--RULE DataHasCorrespondingNotice-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SSI'))]"
                 priority="1000"
                 mode="M404">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SSI'))]"
                       id="DataHasCorrespondingNotice-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('SSI')) and not ($elem/@ism:externalNotice=true()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $elem in $partTags satisfies ($elem[@ism:noticeType] and util:containsAnyOfTheTokens($elem/@ism:noticeType, ('SSI')) and not ($elem/@ism:externalNotice=true()))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>[<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00356'"/>
                  <xsl:text/>][Error] If ISM_USGOV_RESOURCE, any
			element meeting ISM_CONTRIBUTES in the document has the attribute <xsl:text/>
                  <xsl:value-of select="'ism:nonICmarkings'"/>
                  <xsl:text/> containing [<xsl:text/>
                  <xsl:value-of select="'SSI'"/>
                  <xsl:text/>], then some
			element meeting ISM_CONTRIBUTES in the document MUST have attribute noticeType
			containing [<xsl:text/>
                  <xsl:value-of select="'SSI'"/>
                  <xsl:text/>].</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M404"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M404"/>
   <xsl:template match="@*|node()" priority="-2" mode="M404">
      <xsl:apply-templates select="*" mode="M404"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00357-->


	<!--RULE NoticeHasCorrespondingData-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and not (@ism:externalNotice=true()) and util:containsAnyOfTheTokens(@ism:noticeType, ('SSI'))]"
                 priority="1000"
                 mode="M405">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:contributesToRollup(.) and not (@ism:externalNotice=true()) and util:containsAnyOfTheTokens(@ism:noticeType, ('SSI'))]"
                       id="NoticeHasCorrespondingData-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="index-of($partNonICmarkings_tok, 'SSI')&gt;0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="index-of($partNonICmarkings_tok, 'SSI')&gt;0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00357'"/>
                  <xsl:text/>][Error] If ISM_USGOV_RESOURCE and any element meeting
			ISM_CONTRIBUTES in the document has the attribute noticeType containing [<xsl:text/>
                  <xsl:value-of select="'SSI'"/>
                  <xsl:text/>], then some element meeting ISM_CONTRIBUTES in the document
			MUST have attribute <xsl:text/>
                  <xsl:value-of select="'nonICmarkings'"/>
                  <xsl:text/> containing [<xsl:text/>
                  <xsl:value-of select="'SSI'"/>
                  <xsl:text/>]. Human Readable: USA documents containing an <xsl:text/>
                  <xsl:value-of select="'SSI'"/>
                  <xsl:text/> notice must also have <xsl:text/>
                  <xsl:value-of select="'SSI'"/>
                  <xsl:text/> data.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M405"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M405"/>
   <xsl:template match="@*|node()" priority="-2" mode="M405">
      <xsl:apply-templates select="*" mode="M405"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00361-->


	<!--RULE ISM-ID-00361-R1-->
<xsl:template match="*[@ism:hasApproximateMarkings]" priority="1000" mode="M406">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:hasApproximateMarkings]"
                       id="ISM-ID-00361-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:hasApproximateMarkings, $BooleanPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:hasApproximateMarkings, $BooleanPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
		    	[ISM-ID-00361][Error] All hasApproximateMarkings attributes values must be of type Boolean. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M406"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M406"/>
   <xsl:template match="@*|node()" priority="-2" mode="M406">
      <xsl:apply-templates select="*" mode="M406"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00362-->


	<!--RULE ISM-ID-00362-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC-USGOV')) and @ism:SCIcontrols]"
                 priority="1000"
                 mode="M407">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC-USGOV')) and @ism:SCIcontrols]"
                       id="ISM-ID-00362-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(util:getStringFromSequenceWithOnlyRegexValues(@ism:SCIcontrols, 'HCS-P-[A-Z0-9]{1,6}'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:getStringFromSequenceWithOnlyRegexValues(@ism:SCIcontrols, 'HCS-P-[A-Z0-9]{1,6}'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00362][Error] HCS-P-subs cannot be used with OC-USGOV.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M407"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M407"/>
   <xsl:template match="@*|node()" priority="-2" mode="M407">
      <xsl:apply-templates select="*" mode="M407"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00363-->


	<!--RULE ISM-ID-00363-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC-USGOV')) and @ism:SCIcontrols]"
                 priority="1000"
                 mode="M408">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                      and util:containsAnyOfTheTokens(@ism:disseminationControls, ('OC-USGOV')) and @ism:SCIcontrols]"
                       id="ISM-ID-00363-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS-O')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyOfTheTokens(@ism:SCIcontrols, ('HCS-O')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00363][Error] HCS-O cannot be used with OC-USGOV.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M408"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M408"/>
   <xsl:template match="@*|node()" priority="-2" mode="M408">
      <xsl:apply-templates select="*" mode="M408"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00364-->


	<!--RULE ISM-ID-00364-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and string-length(normalize-space(@ism:compilationReason)) &gt; 0 and string-length(normalize-space(@ism:noAggregation)) &gt; 0]"
                 priority="1000"
                 mode="M409">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and string-length(normalize-space(@ism:compilationReason)) &gt; 0 and string-length(normalize-space(@ism:noAggregation)) &gt; 0]"
                       id="ISM-ID-00364-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:noAggregation = false() "/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:noAggregation = false()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00364][Error] If an ISM_USGOV_RESOURCE has a value in @compilationReason and @noAggregation is present,
            @noAggregation must be false.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M409"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M409"/>
   <xsl:template match="@*|node()" priority="-2" mode="M409">
      <xsl:apply-templates select="*" mode="M409"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00365-->


	<!--RULE ISM-ID-00365-R1-->
<xsl:template match="*[@ism:noAggregation]" priority="1000" mode="M410">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:noAggregation]"
                       id="ISM-ID-00365-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:noAggregation, $BooleanPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:noAggregation, $BooleanPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00365][Error] All noAggregation attribute values must be of type Boolean. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M410"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M410"/>
   <xsl:template match="@*|node()" priority="-2" mode="M410">
      <xsl:apply-templates select="*" mode="M410"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00367-->


	<!--RULE ISM-ID-00367-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and @ism:derivedFrom]"
                 priority="1000"
                 mode="M411">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and @ism:derivedFrom]"
                       id="ISM-ID-00367-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(@ism:classifiedBy)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not(@ism:classifiedBy)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00367][Error] USA documents that are derived from other sources must not
        	specify a classified by.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M411"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M411"/>
   <xsl:template match="@*|node()" priority="-2" mode="M411">
      <xsl:apply-templates select="*" mode="M411"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00368-->


	<!--RULE ISM-ID-00368-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-BLFH'))]"
                 priority="1000"
                 mode="M412">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-BLFH'))]"
                       id="ISM-ID-00368-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:classification, ('TS'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:classification, ('TS'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00368][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols
            contains the name token [TK-BLFH], then attribute classification must have
            a value of [TS].
            
            Human Readable: A USA document containing TALENT KEYHOLE (TK) -BLUEFISH compartment data must
            be classified TOP SECRET.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M412"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M412"/>
   <xsl:template match="@*|node()" priority="-2" mode="M412">
      <xsl:apply-templates select="*" mode="M412"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00369-->


	<!--RULE ISM-ID-00369-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-BLFH'))]"
                 priority="1000"
                 mode="M413">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-BLFH'))]"
                       id="ISM-ID-00369-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00369][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols
            contains the name token [TK-BLFH], then attribute disseminationControls
            must contain the name token [NF].
            
            Human Readable: A USA document containing TALENT KEYHOLE (TK) -BLUEFISH compartment data must also be
            marked for NO FOREIGN dissemination.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M413"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M413"/>
   <xsl:template match="@*|node()" priority="-2" mode="M413">
      <xsl:apply-templates select="*" mode="M413"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00370-->


	<!--RULE ISM-ID-00370-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-IDIT'))]"
                 priority="1000"
                 mode="M414">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-IDIT'))]"
                       id="ISM-ID-00370-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00370][Error] If ISM_USGOV_RESOURCE and attribute SCIcontrols
            contains the name token [TK-IDIT], then attribute disseminationControls
            must contain the name token [NF].
            
            Human Readable: A USA document containing TALENT KEYHOLE (TK) -IDITAROD compartment data must also be
            marked for NO FOREIGN dissemination.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M414"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M414"/>
   <xsl:template match="@*|node()" priority="-2" mode="M414">
      <xsl:apply-templates select="*" mode="M414"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00371-->


	<!--RULE ISM-ID-00371-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-KAND'))]"
                 priority="1000"
                 mode="M415">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                         and util:containsAnyOfTheTokens(@ism:SCIcontrols, ('TK-KAND'))]"
                       id="ISM-ID-00371-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00371][Error]If ISM_USGOV_RESOURCE and attribute SCIcontrols
            contains the name token [TK-KAND], then attribute disseminationControls
            must contain the name token [NF].
            
            Human Readable: A USA document containing TALENT KEYHOLE (TK) -KANDIK compartment data must also be
            marked for NO FOREIGN dissemination.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M415"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M415"/>
   <xsl:template match="@*|node()" priority="-2" mode="M415">
      <xsl:apply-templates select="*" mode="M415"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00372-->


	<!--RULE ISM-ID-00372-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE                                  and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES-NF','SBU-NF'))]"
                 priority="1000"
                 mode="M416">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE                                  and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('LES-NF','SBU-NF'))]"
                       id="ISM-ID-00372-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF','REL','EYES','RELIDO','DISPLAYONLY')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyOfTheTokens(@ism:disseminationControls, ('NF','REL','EYES','RELIDO','DISPLAYONLY')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00372][Error] LES-NF and SBU-NF are incompatible with other Foreign Disclosure 
            and Release markings.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M416"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M416"/>
   <xsl:template match="@*|node()" priority="-2" mode="M416">
      <xsl:apply-templates select="*" mode="M416"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00373-->


	<!--RULE AttributeContributesToRollup-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('SSI')))]"
                 priority="1000"
                 mode="M417">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and              (some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('SSI')))]"
                       id="AttributeContributesToRollup-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SSI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SSI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'[ISM-ID-00373][Error] USA documents having SSI Data must have SSI at the resource level.'"/>
                  <xsl:text/> 
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M417"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M417"/>
   <xsl:template match="@*|node()" priority="-2" mode="M417">
      <xsl:apply-templates select="*" mode="M417"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00374-->


	<!--RULE ISM-ID-00374-R1-->
<xsl:template match="*[$ISM_USGOV_RESOURCE         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)         and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SSI'))         and string-length(normalize-space(@ism:compilationReason)) = 0]"
                 priority="1000"
                 mode="M418">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USGOV_RESOURCE         and generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)         and util:containsAnyOfTheTokens(@ism:nonICmarkings, ('SSI'))         and string-length(normalize-space(@ism:compilationReason)) = 0]"
                       id="ISM-ID-00374-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('SSI'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $ele in $partTags satisfies util:containsAnyOfTheTokens($ele/@ism:nonICmarkings, ('SSI'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00374][Error] If @ism:nonICmarkings contains 'SSI' at the resource level, it must be found in a contributing
            portion of the document unless there is a compilation reason of the exception.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M418"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M418"/>
   <xsl:template match="@*|node()" priority="-2" mode="M418">
      <xsl:apply-templates select="*" mode="M418"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00379-->


	<!--RULE ISM-ID-00379-R1-->
<xsl:template match="*[@ism:declassDate]" priority="1000" mode="M419">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:declassDate]"
                       id="ISM-ID-00379-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:declassDate, $DatePattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:declassDate, $DatePattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00379][Error] All declassDate attribute values must be of type Date. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="matches(@ism:declassDate, '[0-9]{4}-[0-9]{2}-[0-9]{2}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(@ism:declassDate, '[0-9]{4}-[0-9]{2}-[0-9]{2}$')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00379][Error] All declassDate attribute values must not have any timezone
            information specified. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M419"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M419"/>
   <xsl:template match="@*|node()" priority="-2" mode="M419">
      <xsl:apply-templates select="*" mode="M419"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00380-->


	<!--RULE ISM-ID-00380-R1-->
<xsl:template match="*[@ism:noticeDate]" priority="1000" mode="M420">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:noticeDate]"
                       id="ISM-ID-00380-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:noticeDate, $DatePattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:noticeDate, $DatePattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00380][Error] All noticeDate attribute values must be of type Date. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="matches(@ism:noticeDate, '[0-9]{4}-[0-9]{2}-[0-9]{2}$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(@ism:noticeDate, '[0-9]{4}-[0-9]{2}-[0-9]{2}$')">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00380][Error] All noticeDate attribute values must not have any timezone
            information specified. </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M420"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M420"/>
   <xsl:template match="@*|node()" priority="-2" mode="M420">
      <xsl:apply-templates select="*" mode="M420"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00119-->


	<!--RULE ISM-ID-00119-R1-->
<xsl:template match="*[@ism:* except (@ism:pocType | @ism:DESVersion | @ism:ISMCATCESVersion | @ism:unregisteredNoticeType)                        and $ISM_USIC_RESOURCE                        and util:contributesToRollup(.)                        and not($ISM_710_FDR_EXEMPT)                        and not(@ism:classification='U')]"
                 priority="1000"
                 mode="M421">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:* except (@ism:pocType | @ism:DESVersion | @ism:ISMCATCESVersion | @ism:unregisteredNoticeType)                        and $ISM_USIC_RESOURCE                        and util:contributesToRollup(.)                        and not($ISM_710_FDR_EXEMPT)                        and not(@ism:classification='U')]"
                       id="ISM-ID-00119-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY', 'RELIDO','REL','EYES', 'NF'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:disseminationControls, ('DISPLAYONLY', 'RELIDO','REL','EYES', 'NF'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00119][Error] If ISM_USIC_RESOURCE and 
            1. attribute classification is not [U]
            AND
            2. not ISM_710_FDR_EXEMPT
            AND
            3. attribute excludeFromRollup is not true
            AND
            4. Attribute disseminationControls must contain one or more of 
            [DISPLAYONLY], [REL], [RELIDO], [EYES], or [NF]
            
            Human Readable: All classified NSI that does not claim exemption from
            ICD 710 mandatory Foreign Disclosure and Release must have an 
            appropriate foreign disclosure or release marking.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M421"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M421"/>
   <xsl:template match="@*|node()" priority="-2" mode="M421">
      <xsl:apply-templates select="*" mode="M421"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00225-->


	<!--RULE ISM-ID-00225-R1-->
<xsl:template match="*[$ISM_USIC_RESOURCE and @ism:nonICmarkings and util:contributesToRollup(.)]"
                 priority="1000"
                 mode="M422">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USIC_RESOURCE and @ism:nonICmarkings and util:contributesToRollup(.)]"
                       id="ISM-ID-00225-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(util:containsAnyTokenMatching(@ism:nonICmarkings, ('ACCM', 'NNPI')))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyTokenMatching(@ism:nonICmarkings, ('ACCM', 'NNPI')))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00225][Error] If not exempt from IC rules, then attribute 
            nonICmarkings must not be specified with a value containing any name 
            token starting with [ACCM] or [NNPI]. 
            
            Human Readable: ACCM and NNPI tokens are not valid for documents that are
            subject to IC rules.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M422"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M422"/>
   <xsl:template match="@*|node()" priority="-2" mode="M422">
      <xsl:apply-templates select="*" mode="M422"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00251-->


	<!--RULE ISM-ID-00251-R1-->
<xsl:template match="*[$ISM_USIC_RESOURCE and @ism:noticeType]"
                 priority="1000"
                 mode="M423">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[$ISM_USIC_RESOURCE and @ism:noticeType]"
                       id="ISM-ID-00251-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(util:containsAnyTokenMatching(@ism:noticeType, 'COMSEC'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(util:containsAnyTokenMatching(@ism:noticeType, 'COMSEC'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00251][Error] If ISM_USIC_RESOURCE, then attribute 
            @ism:noticeType must not be specified with a value of [COMSEC]. 
            
            Human Readable: COMSEC notices are not valid for US IC documents.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M423"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M423"/>
   <xsl:template match="@*|node()" priority="-2" mode="M423">
      <xsl:apply-templates select="*" mode="M423"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00002-->


	<!--RULE ISM-ID-00002-R1-->
<xsl:template match="*[@ism:*]" priority="1000" mode="M424">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:*]"
                       id="ISM-ID-00002-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $attribute in @ism:* satisfies normalize-space(string($attribute))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $attribute in @ism:* satisfies normalize-space(string($attribute))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00002][Error] For every attribute that is used in a 
        	document a non-null value must be present.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M424"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M424"/>
   <xsl:template match="@*|node()" priority="-2" mode="M424">
      <xsl:apply-templates select="*" mode="M424"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00012-->


	<!--RULE ISM-ID-00012-R1-->
<xsl:template match="*[@ism:* except (@ism:pocType | @ism:DESVersion | @ism:unregisteredNoticeType | @ism:ISMCATCESVersion)]"
                 priority="1000"
                 mode="M425">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:* except (@ism:pocType | @ism:DESVersion | @ism:unregisteredNoticeType | @ism:ISMCATCESVersion)]"
                       id="ISM-ID-00012-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:ownerProducer and @ism:classification"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="@ism:ownerProducer and @ism:classification">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00012][Error] If any of the attributes defined in 
        	this DES other than ISMCATCESVersion, DESVersion, unregisteredNoticeType, or pocType 
        	are specified for an element, then attributes classification and 
        	ownerProducer must be specified for the element.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M425"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M425"/>
   <xsl:template match="@*|node()" priority="-2" mode="M425">
      <xsl:apply-templates select="*" mode="M425"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00102-->


	<!--RULE ISM-ID-00102-R1-->
<xsl:template match="/*[descendant-or-self::*[@ism:* except (@ism:ISMCATCESVersion)]]"
                 priority="1000"
                 mode="M426">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/*[descendant-or-self::*[@ism:* except (@ism:ISMCATCESVersion)]]"
                       id="ISM-ID-00102-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="some $element in descendant-or-self::node() satisfies $element/@ism:DESVersion"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $element in descendant-or-self::node() satisfies $element/@ism:DESVersion">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00102][Error] The attribute 
            DESVersion in the namespace urn:us:gov:ic:ism must be specified.
            
            Human Readable: The data encoding specification version must 
            be specified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M426"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M426"/>
   <xsl:template match="@*|node()" priority="-2" mode="M426">
      <xsl:apply-templates select="*" mode="M426"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00103-->


	<!--RULE ISM-ID-00103-R1-->
<xsl:template match="/*[descendant-or-self::*[@ism:* except (@ism:ISMCATCESVersion)]]"
                 priority="1000"
                 mode="M427">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/*[descendant-or-self::*[@ism:* except (@ism:ISMCATCESVersion)]]"
                       id="ISM-ID-00103-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="some $token in //*[(@ism:*)] satisfies               $token/@ism:resourceElement=true()"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $token in //*[(@ism:*)] satisfies $token/@ism:resourceElement=true()">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00103][Error] At least one element must have attribute 
        	resourceElement specified with a value of [true].
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M427"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M427"/>
   <xsl:template match="@*|node()" priority="-2" mode="M427">
      <xsl:apply-templates select="*" mode="M427"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00118-->


	<!--RULE ISM-ID-00118-R1-->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)][1]"
                 priority="1000"
                 mode="M428">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)][1]"
                       id="ISM-ID-00118-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:createDate"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:createDate">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00118][Error] The first element in document order having 
            resourceElement true must have createDate specified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M428"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M428"/>
   <xsl:template match="@*|node()" priority="-2" mode="M428">
      <xsl:apply-templates select="*" mode="M428"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00125-->


	<!--RULE ISM-ID-00125-R1-->
<xsl:template match="*[@ism:*]" priority="1000" mode="M429">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:*]"
                       id="ISM-ID-00125-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $attr in @ism:* satisfies               $attr[local-name() = $validAttributeList]"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $attr in @ism:* satisfies $attr[local-name() = $validAttributeList]">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'         [ISM-ID-00125][Error] If any attributes in namespace          urn:us:gov:ic:ism exist, the local name must exist in CVEnumISMAttributes.xml.                   Human Readable: Ensure that attributes in the ISM namespace are defined by ISM.XML.         '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M429"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M429"/>
   <xsl:template match="@*|node()" priority="-2" mode="M429">
      <xsl:apply-templates select="*" mode="M429"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00163-->


	<!--RULE ISM-ID-00163-R1-->
<xsl:template match="*[@ism:nonUSControls]" priority="1000" mode="M430">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:nonUSControls]"
                       id="ISM-ID-00163-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="(matches(normalize-space(string(@ism:ownerProducer)), '^NATO:?') or matches(normalize-space(string(@ism:FGIsourceOpen)), 'NATO:?')) or @ism:FGIsourceProtected"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="(matches(normalize-space(string(@ism:ownerProducer)), '^NATO:?') or matches(normalize-space(string(@ism:FGIsourceOpen)), 'NATO:?')) or @ism:FGIsourceProtected">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
        	[ISM-ID-00163][Error] If attribute nonUSControls exists the attribute 
        	ownerProducer must equal [NATO].
        	
        	Human Readable: NATO and NATO/NACs are the only owner of classification markings
        	for which nonUSControls are currently authorized.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M430"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M430"/>
   <xsl:template match="@*|node()" priority="-2" mode="M430">
      <xsl:apply-templates select="*" mode="M430"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00194-->


	<!--RULE AttributeValueDeprecatedWarning-R1-->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M431">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:noticeType]"
                       id="AttributeValueDeprecatedWarning-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:noticeType), document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:noticeType), document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, false()))=0">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00194'"/>
                  <xsl:text/>][Warning] For attribute <xsl:text/>
                  <xsl:value-of select="'noticeType'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated(string(@ism:noticeType), document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE,false())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M431"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M431"/>
   <xsl:template match="@*|node()" priority="-2" mode="M431">
      <xsl:apply-templates select="*" mode="M431"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00195-->


	<!--RULE AttributeValueDeprecatedError-R1-->
<xsl:template match="*[@ism:noticeType]" priority="1000" mode="M432">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:noticeType]"
                       id="AttributeValueDeprecatedError-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="count( dvf:deprecated( string(@ism:noticeType), document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="count( dvf:deprecated( string(@ism:noticeType), document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term[./@deprecated], $ISM_RESOURCE_CREATE_DATE, true()) )=0">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [<xsl:text/>
                  <xsl:value-of select="'ISM-ID-00195'"/>
                  <xsl:text/>][Error] For attribute <xsl:text/>
                  <xsl:value-of select="'noticeType'"/>
                  <xsl:text/>, value(s) <xsl:text/>
                  <xsl:value-of select="dvf:deprecated( string(@ism:noticeType), document('../../CVE/ISM/CVEnumISMNotice.xml')//cve:CVE/cve:Enumeration/cve:Term[@deprecated], $ISM_RESOURCE_CREATE_DATE, true())"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M432"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M432"/>
   <xsl:template match="@*|node()" priority="-2" mode="M432">
      <xsl:apply-templates select="*" mode="M432"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00236-->


	<!--RULE ISM-ID-00236-R1-->
<xsl:template match="*[@ism:*]" priority="1000" mode="M433">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:*]"
                       id="ISM-ID-00236-R1"/>
      <xsl:variable name="dupAttrs"
                    select="for $attr in ./(@ism:atomicEnergyMarkings, @ism:classification, @ism:compliesWith, @ism:declassException, @ism:displayOnlyTo, @ism:disseminationControls, @ism:exemptFrom, @ism:FGIsourceOpen, @ism:FGIsourceProtected, @ism:nonICmarkings, @ism:nonUSControls, @ism:noticeType, @ism:ownerProducer, @ism:pocType, @ism:releasableTo, @ism:SARIdentifier, @ism:SCIcontrols) return if(count(distinct-values(tokenize(string($attr),' '))) != count(tokenize(string($attr),' '))                                         and not(local-name($attr)='derivedFrom' or local-name($attr)='classificationReason')) then $attr else null"/>
      <xsl:variable name="hasDups" select="count($dupAttrs)&gt;0"/>
      <xsl:variable name="dupValues"
                    select="if ($hasDups) then  distinct-values(  for $attrib in $dupAttrs return     for $each in tokenize(string($attrib),' ') return     if(count(index-of(tokenize(string($attrib),' '), $each))&gt;1)     then concat(string($each),' in attribute ',$attrib/name(),'; ')     else null)     else null     "/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not($hasDups)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="not($hasDups)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [ISM-ID-00236][Error] Duplicate tokens are
            not permitted in ISM attributes. Duplicate values found: [<xsl:text/>
                  <xsl:value-of select="$dupValues"/>
                  <xsl:text/>]</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M433"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M433"/>
   <xsl:template match="@*|node()" priority="-2" mode="M433">
      <xsl:apply-templates select="*" mode="M433"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00248-->


	<!--RULE ISM-ID-00248-R1-->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)][@ism:externalNotice]"
                 priority="1000"
                 mode="M434">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)][@ism:externalNotice]"
                       id="ISM-ID-00248-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not(string(@ism:externalNotice)=string(true()))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not(string(@ism:externalNotice)=string(true()))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00248][Error] ISM_RESOURCE_ELEMENT cannot have externalNotice set to [true].
			
			Human Readable: ISM resource elements cannot be external notices.
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M434"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M434"/>
   <xsl:template match="@*|node()" priority="-2" mode="M434">
      <xsl:apply-templates select="*" mode="M434"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00300-->


	<!--RULE ISM-ID-00300-R1-->
<xsl:template match="*[@ism:DESVersion]" priority="1000" mode="M435">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:DESVersion]"
                       id="ISM-ID-00300-R1"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="matches(@ism:DESVersion,'^201609.201707(-.{1,23})?$')"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="matches(@ism:DESVersion,'^201609.201707(-.{1,23})?$')">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00300][Warning] DESVersion attributes SHOULD be specified as revision 201609.201707 with an optional extension.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M435"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M435"/>
   <xsl:template match="@*|node()" priority="-2" mode="M435">
      <xsl:apply-templates select="*" mode="M435"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00322-->


	<!--RULE ISM-ID-00322-R1-->
<xsl:template match="*[@ism:ISMCATCESVersion]" priority="1000" mode="M436">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:ISMCATCESVersion]"
                       id="ISM-ID-00322-R1"/>
      <xsl:variable name="version"
                    select="number(if (contains(@ism:ISMCATCESVersion,'-')) then substring-before(@ism:ISMCATCESVersion,'-') else @ism:ISMCATCESVersion)"/>

		    <!--ASSERT warning-->
<xsl:choose>
         <xsl:when test="$version &gt;= 201707"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$version &gt;= 201707">
               <xsl:attribute name="flag">warning</xsl:attribute>
               <xsl:attribute name="role">warning</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00322][Warning] The @ism:ISMCATCESVersion imported by ISM SHOULD be greater than or equal to 201707.
            
            Human Readable: The ISMCAT version imported by ISM SHOULD be greater than or equal to 2017-JUL. 
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M436"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M436"/>
   <xsl:template match="@*|node()" priority="-2" mode="M436">
      <xsl:apply-templates select="*" mode="M436"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00323-->


	<!--RULE ISM-ID-00323-R1-->
<xsl:template match="/" priority="1000" mode="M437">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/"
                       id="ISM-ID-00323-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="some $element in descendant-or-self::node() satisfies $element/@ism:ISMCATCESVersion"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="some $element in descendant-or-self::node() satisfies $element/@ism:ISMCATCESVersion">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00323][Error] The attribute 
            ISMCATCESVersion in the namespace urn:us:gov:ic:ism must be specified.
            
            Human Readable: The CVE encoding specification version for ISM CAT must
            be specified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M437"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M437"/>
   <xsl:template match="@*|node()" priority="-2" mode="M437">
      <xsl:apply-templates select="*" mode="M437"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00337-->


	<!--RULE ISM-ID-00337-R1-->
<xsl:template match="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)][1]"
                 priority="1000"
                 mode="M438">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)][1]"
                       id="ISM-ID-00337-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="@ism:compliesWith"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="@ism:compliesWith">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00337][Error] The first element in document order having 
            resourceElement true must have compliesWith specified.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M438"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M438"/>
   <xsl:template match="@*|node()" priority="-2" mode="M438">
      <xsl:apply-templates select="*" mode="M438"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00338-->


	<!--RULE ValidateTokenValuesExistenceInList-R1-->
<xsl:template match="*[@ism:compliesWith]" priority="1000" mode="M439">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:compliesWith]"
                       id="ValidateTokenValuesExistenceInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(@ism:compliesWith)), ' ') satisfies                   $searchTerm = $compliesWithList or (some $Term in $compliesWithList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(@ism:compliesWith)), ' ') satisfies $searchTerm = $compliesWithList or (some $Term in $compliesWithList satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'         [ISM-ID-00338][Error] All @ism:compliesWith values must         be defined in CVEnumISMCompliesWith.xml.         '"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M439"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M439"/>
   <xsl:template match="@*|node()" priority="-2" mode="M439">
      <xsl:apply-templates select="*" mode="M439"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00339-->


	<!--RULE ISM-ID-00339-R1-->
<xsl:template match="*[ generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)         and util:containsAnyOfTheTokens(@ism:ownerProducer, ('USA'))]"
                 priority="1000"
                 mode="M440">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[ generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT)         and util:containsAnyOfTheTokens(@ism:ownerProducer, ('USA'))]"
                       id="ISM-ID-00339-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="             util:containsAnyOfTheTokens(@ism:compliesWith, ('USGov'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:compliesWith, ('USGov'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> [ISM-ID-00339][Error] 
            1. ism:ownerProducer of resource element contains USA
            2. ism:compliesWith does not contain USGov
            
            Human Readable: All documents that contain USA in @ism:ownerProducer of
            the first resource node (in document order) must claim USGov in @ism:compliesWith
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M440"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M440"/>
   <xsl:template match="@*|node()" priority="-2" mode="M440">
      <xsl:apply-templates select="*" mode="M440"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00340-->


	<!--RULE ISM-ID-00340-R1-->
<xsl:template match="*[@ism:compliesWith]" priority="1000" mode="M441">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:compliesWith]"
                       id="ISM-ID-00340-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:compliesWith, $NmTokensPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:compliesWith, $NmTokensPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00340][Error] All compliesWith attributes values must be of type NmTokens. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M441"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M441"/>
   <xsl:template match="@*|node()" priority="-2" mode="M441">
      <xsl:apply-templates select="*" mode="M441"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00358-->


	<!--RULE ISM-ID-00358-R1-->
<xsl:template match="*[@ism:resourceElement=true()][1]"
                 priority="1000"
                 mode="M442">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:resourceElement=true()][1]"
                       id="ISM-ID-00358-R1"/>
      <xsl:variable name="op"
                    select="if(@ism:joint=true()) then @ism:ownerProducer else ''"/>
      <xsl:variable name="releasableToCountries"
                    select="distinct-values(for $value in tokenize(normalize-space(concat(@ism:releasableTo,' ',$op)),' ') return      if(index-of($catt//catt:TetraToken,$value)&gt;0)      then util:tokenize(util:getTetragraphMembership($value))      else $value)"/>
      <xsl:variable name="tetrasWithReleasableTo"
                    select="distinct-values(for $value in $tetras return        if($catt//catt:Tetragraph[catt:TetraToken=$value]/@ism:releasableTo)         then $value        else null)"/>
      <xsl:variable name="moreRestrictiveTetras"
                    select="for $tetra in $tetrasWithReleasableTo return       if (every $value in $releasableToCountries satisfies index-of(distinct-values(util:tokenize(util:getTetragraphReleasability($tetra))),$value)&gt;0)        then null else $tetra"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="empty($moreRestrictiveTetras)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="empty($moreRestrictiveTetras)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
		    	[ISM-ID-00358][Error] A document using tetragraphs may not have a releasableTo or 
		    	that is less restrictive than that of any tetragraph or organization 
		    	tokens used in the releasableTo fields. The following tetragraphs
		    	have a more restrictive releasability than the document: 
		    	<xsl:text/>
                  <xsl:value-of select="string-join($moreRestrictiveTetras,', ')"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists($catt//catt:Tetragraphs)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists($catt//catt:Tetragraphs)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>CATT does not exist!</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M442"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M442"/>
   <xsl:template match="@*|node()" priority="-2" mode="M442">
      <xsl:apply-templates select="*" mode="M442"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00359-->


	<!--RULE ISM-ID-00359-R1-->
<xsl:template match="*[@ism:resourceElement=true()][1]"
                 priority="1000"
                 mode="M443">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:resourceElement=true()][1]"
                       id="ISM-ID-00359-R1"/>
      <xsl:variable name="documentClassification" select="@ism:classification"/>
      <xsl:variable name="moreRestrictiveTetras"
                    select="for $tetra in $tetras return              if ($catt//catt:Tetragraph[catt:TetraToken=$tetra]/@ism:classification != $documentClassification)              then             (if ($documentClassification = 'TS')             then null             else if ($catt//catt:Tetragraph[catt:TetraToken=$tetra]/@ism:classification = 'TS')             then $tetra             else if ($documentClassification = 'U')             then $tetra             else if ($documentClassification = 'C' and $catt//catt:Tetragraph[catt:TetraToken=$tetra]/@ism:classification = 'S')             then $tetra             else if ($documentClassification = 'R' and ($catt//catt:Tetragraph[catt:TetraToken=$tetra]/@ism:classification = 'C' or $catt//catt:Tetragraph[catt:TetraToken=$tetra]/@ism:classification = 'S'))             then $tetra             else             null             )             else null"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="empty($moreRestrictiveTetras)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="empty($moreRestrictiveTetras)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00359][Error] A document using tetragraphs may not have a classification that is greater
            than the classification of the document. The following tetragraphs
            have a more restrictive classification than the document: 
            <xsl:text/>
                  <xsl:value-of select="string-join($moreRestrictiveTetras,', ')"/>
                  <xsl:text/>.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists($catt//catt:Tetragraphs)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists($catt//catt:Tetragraphs)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>CATT does not exist!</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M443"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M443"/>
   <xsl:template match="@*|node()" priority="-2" mode="M443">
      <xsl:apply-templates select="*" mode="M443"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00360-->


	<!--RULE ISM-ID-00360-R1-->
<xsl:template match="*[@ism:resourceElement=true()][1]"
                 priority="1000"
                 mode="M444">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:resourceElement=true()][1]"
                       id="ISM-ID-00360-R1"/>
      <xsl:variable name="documentClassification" select="@ism:classification"/>
      <xsl:variable name="documentIsFOUO"
                    select="some $dissem in tokenize(@ism:disseminationControls, ' ') satisfies $dissem eq 'FOUO'"/>
      <xsl:variable name="tetrasWithFOUO"
                    select="distinct-values(for $value in $tetras return              if($catt//catt:Tetragraph[catt:TetraToken=$value]/@ism:ownerProducer and (some $dissem in tokenize($catt//catt:Tetragraph[catt:TetraToken=$value]/@ism:disseminationControls, ' ') satisfies $dissem eq 'FOUO'))              then $value             else null)"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="not($documentClassification = 'U' and not($documentIsFOUO) and not(empty($tetrasWithFOUO)))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="not($documentClassification = 'U' and not($documentIsFOUO) and not(empty($tetrasWithFOUO)))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00360][Error] An UNCLASSIFIED document may not use FOUO tetragraphs unless the document is also FOUO.
            The following tetragraphs are UNCLASSIFIED//FOUO: 
            <xsl:text/>
                  <xsl:value-of select="string-join($tetrasWithFOUO,', ')"/>
                  <xsl:text/>.
            Document classification:
            <xsl:text/>
                  <xsl:value-of select="$documentClassification"/>
                  <xsl:text/>
            Document is FOUO:
            <xsl:text/>
                  <xsl:value-of select="$documentIsFOUO"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists($catt//catt:Tetragraphs)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists($catt//catt:Tetragraphs)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>CATT does not exist!</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M444"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M444"/>
   <xsl:template match="@*|node()" priority="-2" mode="M444">
      <xsl:apply-templates select="*" mode="M444"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00366-->


	<!--RULE ISM-ID-00366-R1-->
<xsl:template match="*[@ntk:DESVersion]" priority="1000" mode="M445">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ntk:DESVersion]"
                       id="ISM-ID-00366-R1"/>
      <xsl:variable name="version"
                    select="number(if (contains(@ntk:DESVersion,'-')) then substring-before(@ntk:DESVersion,'-') else @ntk:DESVersion)"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="$version &gt;= 201508"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl" test="$version &gt;= 201508">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00366][Error] The @ntk:DESVersion is less than the minimum version 
            allowed: 201508. 
            
            Human Readable: The NTK version imported by ISM must be greater than or equal to 2015-AUG.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M445"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M445"/>
   <xsl:template match="@*|node()" priority="-2" mode="M445">
      <xsl:apply-templates select="*" mode="M445"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00375-->


	<!--RULE ISM-ID-00375-R1-->
<xsl:template match="/" priority="1000" mode="M446">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="/"
                       id="ISM-ID-00375-R1"/>
      <xsl:variable name="cve"
                    select="document('../../CVE/ISMCAT/CVEnumISMCATTetragraph.xml')//cve:CVE"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="$cve/@specVersion &gt;= 201707"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="$cve/@specVersion &gt;= 201707">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
            [ISM-ID-00375][Error] The version of ISMCAT being used in the validation infrastructure is missing essential
            components required for ISM validation to proceed. Regardless of the version indicated on the instance 
            document, the validation infrastructure needs to use a minimum version of ISMCAT that is 2017-JUL or later.
        </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M446"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M446"/>
   <xsl:template match="@*|node()" priority="-2" mode="M446">
      <xsl:apply-templates select="*" mode="M446"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00376-->


	<!--RULE ISM-ID-00376-R1-->
<xsl:template match="*[@ism:ownerProducer]" priority="1000" mode="M447">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:ownerProducer]"
                       id="ISM-ID-00376-R1"/>
      <xsl:variable name="releasableToCountries"
                    select="distinct-values(for $value in tokenize(normalize-space(@ism:releasableTo),' ') return      if(index-of($catt//catt:TetraToken,$value)&gt;0)      then util:tokenize(util:getTetragraphMembership($value))      else $value)"/>
      <xsl:variable name="myTetras"
                    select="for $value in distinct-values(for $each in distinct-values((@ism:ownerProducer | @ism:releasableTo | @ism:displayOnlyTo | @ism:FGIsourceOpen | @ism:FGIsourceProtected)) return util:tokenize($each)) return if ($catt//catt:Tetragraph[catt:TetraToken=$value]) then $value else null"/>
      <xsl:variable name="tetrasWithReleasableTo"
                    select="distinct-values(for $value in $myTetras return        if($catt//catt:Tetragraph[catt:TetraToken=$value]/@ism:releasableTo)         then $value        else null)"/>
      <xsl:variable name="moreRestrictiveTetras"
                    select="for $tetra in $tetrasWithReleasableTo return       if (every $value in $releasableToCountries satisfies index-of(distinct-values(util:tokenize(util:getTetragraphReleasability($tetra))),$value)&gt;0)        then null else $tetra"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="empty($moreRestrictiveTetras)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="empty($moreRestrictiveTetras)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
		    	[ISM-ID-00376][Error] A portion using tetragraphs may not have a releasableTo 
		    	that is less restrictive than the releasability of any tetragraph or organization tokens used
		    	in the same portion’s releasableTo, displayOnlyto, FGISourceOpen, or FGISourceProtected fields.
		    	The following tetragraphs have a more restrictive releasability than the portion: 
		    	<xsl:text/>
                  <xsl:value-of select="string-join($moreRestrictiveTetras,', ')"/>
                  <xsl:text/>
		             </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>

		    <!--ASSERT -->
<xsl:choose>
         <xsl:when test="exists($catt//catt:Tetragraphs)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="exists($catt//catt:Tetragraphs)">
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>CATT does not exist!</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M447"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M447"/>
   <xsl:template match="@*|node()" priority="-2" mode="M447">
      <xsl:apply-templates select="*" mode="M447"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00377-->


	<!--RULE ValidateTokenValuesExistenceInList-R1-->
<xsl:template match="*[@ism:ownerProducer and  @ism:joint=true()]"
                 priority="1000"
                 mode="M448">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:ownerProducer and  @ism:joint=true()]"
                       id="ValidateTokenValuesExistenceInList-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="every $searchTerm in tokenize(normalize-space(string(normalize-space(string(./@ism:ownerProducer)))), ' ') satisfies                   $searchTerm = tokenize(normalize-space(string(@ism:releasableTo)), ' ') or (some $Term in tokenize(normalize-space(string(@ism:releasableTo)), ' ') satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="every $searchTerm in tokenize(normalize-space(string(normalize-space(string(./@ism:ownerProducer)))), ' ') satisfies $searchTerm = tokenize(normalize-space(string(@ism:releasableTo)), ' ') or (some $Term in tokenize(normalize-space(string(@ism:releasableTo)), ' ') satisfies (matches(normalize-space($searchTerm), concat('^', $Term ,'$'))))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
                  <xsl:text/>
                  <xsl:value-of select="'         [ISM-ID-00377][Error] All @ism:ownerProducer values in a JOINT document must be in the ism::releasableTo attribute'"/>
                  <xsl:text/>
               </svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M448"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M448"/>
   <xsl:template match="@*|node()" priority="-2" mode="M448">
      <xsl:apply-templates select="*" mode="M448"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00378-->


	<!--RULE ISM-ID-00378-R1-->
<xsl:template match="*[@ism:joint]" priority="1000" mode="M449">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[@ism:joint]"
                       id="ISM-ID-00378-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:meetsType(@ism:joint, $BooleanPattern)"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:meetsType(@ism:joint, $BooleanPattern)">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text>
			[ISM-ID-00378][Error] All joint attributes values must be of type Boolean. 
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M449"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M449"/>
   <xsl:template match="@*|node()" priority="-2" mode="M449">
      <xsl:apply-templates select="*" mode="M449"/>
   </xsl:template>

   <!--PATTERN ISM-ID-00381-->


	<!--RULE ISM-ID-00381-R1-->
<xsl:template match="*[ generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and        util:containsAnyOfTheTokens(@ism:compliesWith, ('USIC','USDOD'))]"
                 priority="1000"
                 mode="M450">
      <svrl:fired-rule xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                       context="*[ generate-id(.) = generate-id($ISM_RESOURCE_ELEMENT) and        util:containsAnyOfTheTokens(@ism:compliesWith, ('USIC','USDOD'))]"
                       id="ISM-ID-00381-R1"/>

		    <!--ASSERT error-->
<xsl:choose>
         <xsl:when test="util:containsAnyOfTheTokens(@ism:compliesWith, ('USGov'))"/>
         <xsl:otherwise>
            <svrl:failed-assert xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
                                test="util:containsAnyOfTheTokens(@ism:compliesWith, ('USGov'))">
               <xsl:attribute name="flag">error</xsl:attribute>
               <xsl:attribute name="role">error</xsl:attribute>
               <xsl:attribute name="location">
                  <xsl:apply-templates select="." mode="schematron-select-full-path"/>
               </xsl:attribute>
               <svrl:text> 
			[ISM-ID-00381][Error] 
			1. ism:compliesWith of resource element contains USIC or USDOD
			2. ism:compliesWith must also contain USGov
			
			Human Readable: All documents that contain USIC or USDOD in @ism:compliesWith of
			the first resource node (in document order) must also contain USGov in @ism:compliesWith
		</svrl:text>
            </svrl:failed-assert>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" mode="M450"/>
   </xsl:template>
   <xsl:template match="text()" priority="-1" mode="M450"/>
   <xsl:template match="@*|node()" priority="-2" mode="M450">
      <xsl:apply-templates select="*" mode="M450"/>
   </xsl:template>
</xsl:stylesheet>
<!--UNCLASSIFIED-->
