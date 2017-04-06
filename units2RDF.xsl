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
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="&xsd;" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:rdf="&rdf;" xmlns:rdfs="&rdfs;" xmlns:owl="&owl;" xmlns:skos="&skos;" xmlns:dct="&dct;" xmlns:plib="&plib;" xmlns:qudt="&qudt;" xmlns:schema="&schema;" xmlns:ontoml="urn:iso:std:iso:is:13584:-32:ed-1:tech:xml-schema:ontoml" xmlns:UnitsML="urn:oasis:names:tc:unitsml:schema:xsd:UnitsMLSchema-1.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:oasis:names:tc:unitsml:schema:xsd:UnitsMLSchema-1.0 http://www.paradine.net/schema/dictionary/1.0/unitml/UnitsML-v1.0-csd02.xsd" exclude-result-prefixes="xsl xs fo fn xsi UnitsML">
	<xsl:import href="irdi2uri.xsl"/>
	<xsl:output indent="yes"/>
	<xsl:key name="class-lkp" match="/ontoml:ontoml/dictionary/contained_classes/ontoml:class" use="described_by/property/@property_ref"/>
	<!-- root element -->
	<xsl:template match="UnitsML:UnitsML">
		<rdf:RDF>
			<xsl:apply-templates/>
		</rdf:RDF>
	</xsl:template>
	<!-- unit templates -->
	<xsl:template match="UnitsML:UnitSet">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="UnitsML:Unit">
		<plib:Unit rdf:about="{ontoml:irdi2defuri(UnitsML:CodeListValue[@codeListName='IRDI']/@unitCodeValue)}">
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</plib:Unit>
	</xsl:template>
	<xsl:template match="UnitsML:Unit/@dimensionURL">
		<plib:hasDimension rdf:resource="{ontoml:irdi2defuri(.)}"/>
	</xsl:template>
	<xsl:template match="UnitsML:UnitName">
		<xsl:if test="@xml:lang='en-US'">
			<rdfs:label>
				<xsl:value-of select="."/>
			</rdfs:label>
		</xsl:if>
		<rdfs:label xml:lang="{lower-case(@xml:lang)}">
			<xsl:value-of select="."/>
		</rdfs:label>
	</xsl:template>
	<xsl:template match="UnitsML:CodeListValue[@codeListName='IRDI']">
		<plib:irdi>
			<xsl:value-of select="@unitCodeValue"/>
		</plib:irdi>
	</xsl:template>
	<xsl:template match="UnitsML:CodeListValue[@codeListName='DIN code']">
		<plib:DINcode>
			<xsl:value-of select="@unitCodeValue"/>
		</plib:DINcode>
	</xsl:template>
	<xsl:template match="UnitsML:Conversions">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="UnitsML:Float64ConversionFrom">
		<plib:hasConversion>
			<plib:Float64Conversion>
				<xsl:apply-templates select="@*"/>
			</plib:Float64Conversion>
		</plib:hasConversion>
	</xsl:template>
	<xsl:template match="@divisor">
		<plib:divisor rdf:datatype="&xsd;double">
			<xsl:value-of select="."/>
		</plib:divisor>
	</xsl:template>
	<xsl:template match="@multiplicand">
		<plib:multiplicand rdf:datatype="&xsd;double">
			<xsl:value-of select="."/>
		</plib:multiplicand>
	</xsl:template>
	<xsl:template match="UnitsML:QuantityReference">
		<plib:hasQuantity rdf:resource="{ontoml:irdi2defuri(@url)}"/>
	</xsl:template>
	<!-- quantity templates -->
	<!-- dimension templates -->
	<!-- Ignore all other nodes -->
	<xsl:template match="node() | @*"/>
</xsl:stylesheet>
