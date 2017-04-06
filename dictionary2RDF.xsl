<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl [
	<!ENTITY skos "http://www.w3.org/2004/02/skos/core#">
	<!ENTITY dct "http://purl.org/dc/terms/">
	<!ENTITY rdf "http://www.w3.org/1999/02/22-rdf-syntax-ns#">
	<!ENTITY rdfs "http://www.w3.org/2000/01/rdf-schema#">
	<!ENTITY plib "http://purl.org/plib/dictionary.owl#">
	<!ENTITY owl "http://www.w3.org/2002/07/owl#">
	<!ENTITY xsd "http://www.w3.org/2001/XMLSchema#">
	<!ENTITY qudt "http://qudt.org/schema/qudt#">
	<!ENTITY schema "http://schema.org/">
]>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="&xsd;" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:rdf="&rdf;" xmlns:rdfs="&rdfs;" xmlns:owl="&owl;" xmlns:skos="&skos;" xmlns:dct="&dct;" xmlns:plib="&plib;" xmlns:qudt="&qudt;" xmlns:schema="&schema;" xmlns:val="urn:iso:std:iso:ts:29002:-10:ed-1:tech:xml-schema:value" xmlns:ontoml="urn:iso:std:iso:is:13584:-32:ed-1:tech:xml-schema:ontoml" xmlns:eptos="urn:x-ontoml-extensions:schema:core" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:iso:std:iso:is:13584:-32:ed-1:tech:xml-schema:ontoml http://www.paradine.net/schema/dictionary/1.0/ontoML/eptosXML.xsd" exclude-result-prefixes="xsl xs fo fn xsi val ontoml eptos">
	<xsl:import href="irdi2uri.xsl"/>
	<xsl:output indent="no"/>
	<xsl:variable name="global_language" select="/ontoml:ontoml/header/global_language/@language_code"/>
	<xsl:key name="class-lkp" match="/ontoml:ontoml/dictionary/contained_classes/ontoml:class" use="described_by/property/@property_ref"/>
	<!-- root element -->
	<xsl:template match="ontoml:ontoml">
		<rdf:RDF>
			<xsl:apply-templates/>
		</rdf:RDF>
	</xsl:template>
	<!-- header templates -->
	<xsl:template match="header">
		<owl:Ontology rdf:about="{ontoml:irdi2uri(@id)}">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</owl:Ontology>
	</xsl:template>
	<xsl:template match="date_time_stamp">
		<dct:created rdf:datatype="&xsd;dateTime">
			<xsl:value-of select="."/>
		</dct:created>
	</xsl:template>
	<xsl:template match="ontoml_information">
		<xsl:apply-templates/>
	</xsl:template>
	<!-- dictionary templates -->
	<xsl:template match="dictionary">
		<xsl:apply-templates/>
	</xsl:template>
	<!-- class templates -->
	<xsl:template match="contained_classes">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="ontoml:class">
		<rdfs:Class rdf:about="{ontoml:irdi2defuri(@id)}">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</rdfs:Class>
	</xsl:template>
	<xsl:template match="its_superclass">
		<rdfs:subClassOf rdf:resource="{ontoml:irdi2defuri(@class_ref)}"/>
	</xsl:template>
	<xsl:template match="is_case_of">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="is_case_of/class">
		<plib:isCaseOf rdf:resource="{ontoml:irdi2defuri(@class_ref)}"/>
	</xsl:template>
	<!-- property templates -->
	<xsl:template match="contained_properties">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="ontoml:property">
		<xsl:variable name="property" select="@id"/>
		<rdf:Property rdf:about="{ontoml:irdi2defuri($property)}">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
			<xsl:variable name="classes" select="key('class-lkp', $property)"/>
			<xsl:for-each select="$classes">
				<!-- we only want to include domain information for the top-level class(es) where a property is assigned -->
				<!-- so here we test if the superclass of the current class does not exist in the list of classes where the property is assigned -->
				<xsl:if test="empty(index-of($classes/@id,its_superclass/@class_ref))">
					<schema:domainIncludes rdf:resource="{ontoml:irdi2defuri(@id)}"/>
				</xsl:if>
			</xsl:for-each>
		</rdf:Property>
	</xsl:template>
	<xsl:template match="preferred_symbol">
		<qudt:symbol rdf:datatype="http://www.w3.org/1999/02/22-rdf-syntax-ns#HTML">
			<xsl:value-of select="eptos:html_representation"/>
		</qudt:symbol>
	</xsl:template>
	<xsl:template match="domain[@xsi:type='ontoml:STRING_TYPE_Type']">
		<rdfs:range rdf:resource="&xsd;string"/>
	</xsl:template>
	<xsl:template match="domain[@xsi:type='ontoml:DATE_DATA_TYPE_Type']">
		<rdfs:range rdf:resource="&xsd;date"/>
	</xsl:template>
	<xsl:template match="domain[@xsi:type='ontoml:DATE_TIME_DATA_TYPE_Type']">
		<rdfs:range rdf:resource="&xsd;dateTime"/>
	</xsl:template>
	<xsl:template match="domain[@xsi:type='ontoml:NAMED_TYPE_Type']">
		<rdfs:range rdf:resource="{ontoml:irdi2defuri(referred_type/@datatype_ref)}"/>
	</xsl:template>
	<xsl:template match="domain[@xsi:type='ontoml:CLASS_REFERENCE_TYPE_Type']">
		<rdfs:range rdf:resource="{ontoml:irdi2defuri(domain/@class_ref)}"/>
	</xsl:template>
	<xsl:template match="domain[@xsi:type='ontoml:REAL_TYPE_Type']">
		<rdfs:range rdf:resource="&xsd;float"/>
	</xsl:template>
	<xsl:template match="domain[@xsi:type='ontoml:INT_TYPE_Type']">
		<rdfs:range rdf:resource="&xsd;integer"/>
	</xsl:template>
	<xsl:template match="domain[@xsi:type='ontoml:REAL_MEASURE_TYPE_Type']">
		<rdfs:range rdf:resource="&plib;QuantitativeValue"/>
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="domain[@xsi:type='ontoml:INT_MEASURE_TYPE_Type']">
		<rdfs:range rdf:resource="&plib;QuantitativeValue"/>
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="domain[@xsi:type='ontoml:LEVEL_TYPE_Type']">
		<rdfs:range rdf:resource="&plib;QuantitativeLevelTypeValue"/>
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="value_type">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="unit">
		<plib:hasBaseUnit rdf:resource="{ontoml:irdi2defuri(@unit_ref)}"/>
	</xsl:template>
	<!-- enumeration templates -->
	<xsl:template match="contained_datatypes">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="ontoml:datatype">
		<xsl:variable name="classUrl" select="ontoml:irdi2defuri(@id)"/>
		<rdfs:Class rdf:about="{$classUrl}">
			<rdfs:subClassOf rdf:resource="&plib;PredefinedValue"/>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</rdfs:Class>
		<xsl:apply-templates select="type_definition/constraints/constraint/value_meaning/its_values/dic_value">
			<xsl:with-param name="classUrl" select="$classUrl"/>
		</xsl:apply-templates>
	</xsl:template>
	<xsl:template match="dic_value">
		<xsl:param name="classUrl"/>
		<xsl:variable name="value_code" select="number(value_code)"/>
		<rdf:Description rdf:about="{ontoml:irdi2defuri(@value_meaning_id)}" rdf:type="{$classUrl}">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
			<rdfs:label>
				<xsl:value-of select="../../../subset/val:string_value[$value_code]"/>
			</rdfs:label>
		</rdf:Description>
	</xsl:template>
	<!-- extensions templates -->
	<xsl:template match="eptos:extensions">
		<xsl:apply-templates/>
	</xsl:template>
	<!-- units templates -->
	<xsl:template match="eptos:contained_units">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="eptos:complete_unit">
		<rdfs:Resource rdf:about="{ontoml:irdi2defuri(@id)}">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</rdfs:Resource>
	</xsl:template>
	<xsl:template match="eptos:DIN_notation">
		<qudt:symbol>
			<xsl:value-of select="."/>
		</qudt:symbol>
	</xsl:template>
	<!-- common templates -->
	<xsl:template match="preferred_name">
		<xsl:for-each select="label[text() != '']">
			<skos:prefLabel>
				<xsl:apply-templates select="."/>
			</skos:prefLabel>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="definition">
		<xsl:for-each select="text[text() != '-']">
			<skos:definition>
				<xsl:apply-templates select="."/>
			</skos:definition>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="note">
		<xsl:for-each select="text">
			<skos:scopeNote>
				<xsl:apply-templates select="."/>
			</skos:scopeNote>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="label | text">
		<xsl:choose>
			<xsl:when test="@language_code!='' and @country_code!=''">
				<xsl:attribute name="xml:lang" select="concat(@language_code,'-',@country_code)"/>
			</xsl:when>
			<xsl:when test="@language_code!=''">
				<xsl:attribute name="xml:lang" select="@language_code"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="xml:lang" select="$global_language"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:value-of select="."/>
	</xsl:template>
	<xsl:template match="@id | @value_meaning_id">
		<plib:irdi>
			<xsl:value-of select="."/>
		</plib:irdi>
	</xsl:template>
	<!-- Ignore all other nodes -->
	<xsl:template match="node() | @*"/>
</xsl:stylesheet>
