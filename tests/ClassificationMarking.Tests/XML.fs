module ClassificationMarking.Tests.XML

open ClassificationMarking.Types

type AtomicEnergyMarking =
    | ``RD-SG-14``
    | ``RD-SG-15``
    | ``RD-SG-18``
    | ``RD-SG-20``
    | ``FRD-SG-14``
    | ``FRD-SG-15``
    | ``FRD-SG-18``
    | ``FRD-SG-20``
    | RD
    | ``RD-CNWDI``
    | FRD
    | DNCI
    | UCNI
    | TFNI
    with
    member this.description =
        match this with
        | ``RD-SG-14`` -> $"RESTRICTED DATA-SIGMA 14"
        | ``RD-SG-15`` -> $"RESTRICTED DATA-SIGMA 15"
        | ``RD-SG-18`` -> $"RESTRICTED DATA-SIGMA 18"
        | ``RD-SG-20`` -> $"RESTRICTED DATA-SIGMA 20"
        | ``FRD-SG-14`` -> $"FORMERLY RESTRICTED DATA-SIGMA 14"
        | ``FRD-SG-15`` -> $"FORMERLY RESTRICTED DATA-SIGMA 15"
        | ``FRD-SG-18`` -> $"FORMERLY RESTRICTED DATA-SIGMA 18"
        | ``FRD-SG-20`` -> $"FORMERLY RESTRICTED DATA-SIGMA 20"
        | RD -> "RESTRICTED DATA"
        | ``RD-CNWDI`` -> "RESTRICTED DATA-CRITICAL NUCLEAR WEAPON DESIGN INFORMATION"
        | FRD -> "FORMERLY RESTRICTED DATA"
        | DNCI -> "DoD CONTROLLED NUCLEAR INFORMATION"
        | UCNI -> "DoE CONTROLLED NUCLEAR INFORMATION"
        | TFNI -> "TRANSCLASSIFIED FOREIGN NUCLEAR INFORMATION"

/// Applicable atomic energy information markings for a document or portion
/// todo possible limited to 1000 values
type AtomicEnergyMarkings = AtomicEnergyMarking list

/// The highest level of classification applicable to the containing document or portion
type Classification =
    | R
    | C
    | S
    | TS
    | U
    with
    member this.description =
        match this with
        | R -> "RESTRICTED"
        | C -> "CONFIDENTIAL"
        | S -> "SECRET"
        | TS -> "TOP SECRET"
        | U -> "UNCLASSIFIED"

/// One or more reason indicators or explanatory text describing the basis for an original classification decision
type ClassificationReason = private ClassificationReason of string
    with
    static member create (str: string) =
        if str.Length <= 4096
        then Ok (ClassificationReason str)
        else Error "Classification reason has a maximum length of 4096 characters"

/// The identity, by name or personal identifier and position title, of the original classification authority for a document
type ClassifiedBy = private ClassifiedBy of string
    with
    static member create (str: string) =
        if str.Length <= 1024
        then Ok (ClassifiedBy str)
        else Error "Classified by has a maximum length of 1024 characters"

/// The reason that the classification of the document is more restrictive than the simple roll-up of
/// the marked portions of the document
type CompilationReason = private CompilationReason of string
    with
    static member create (str: string) =
        if str.Length <= 1024
        then Ok (CompilationReason str)
        else Error "Compilation reason has a maximum length of 1024 characters"

type ComplyWith =
    | USGov
    | USIC
    | USDOD
    | OtherAuthority

/// The ISM rule sets a document complies with
/// todo possible limited to 4 values
type CompliesWith = ComplyWith list

/// The date when ISM metadata was added or updated
type CreateDate = CreateDate of NodaTime.LocalDate

/// The specific date when the resource is subject to automatic declassification procedures if not properly
/// exempted from automatic declassification
type DeclassDate = DeclassDate of NodaTime.LocalDate

/// A description of an event upon which the information shall be subject to automatic declassification
/// procedures if not properly exempted from automatic declassification
type DeclassEvent = private DeclassEvent of string
    with
    static member create (str: string) =
        if str.Length <= 1024
        then Ok (DeclassEvent str)
        else Error "Declassification event has a maximum length of 1024 characters"

/// The exemption from automatic declassification that is claimed for a document
type DeclassException =
    | AEA
    | NATO
    | ``NATO-AEA``
    | TwentyFiveX1
    | ``TwentyFiveX1-EO-12951``
    | TwentyFiveX2
    | TwentyFiveX3
    | TwentyFiveX4
    | TwentyFiveX5
    | TwentyFiveX6
    | TwentyFiveX7
    | TwentyFiveX8
    | TwentyFiveX9
    | FiftyX1
    | ``FiftyX1-HUM``
    | FiftyX2
    | ``FiftyX2-WMD``
    | FiftyX3
    | FiftyX4
    | FiftyX5
    | FiftyX6
    | FiftyX7
    | FiftyX8
    | FiftyX9

/// The identity, by name or personal identifier, of the derivative classification authority
type DerivativelyClassifiedBy = private DerivativelyClassifiedBy of string
    with
    static member create (str: string) =
        if str.Length <= 1024
        then Ok (DerivativelyClassifiedBy str)
        else Error "Derivatively classified by has a maximum length of 1024 characters"

/// A citation of the authoritative source or sources of the classification markings used in a
/// derivative classification decision for a classified document
type DerivedFrom = private DerivedFrom of string
    with
    static member create (str: string) =
        if str.Length <= 1024
        then Ok (DerivedFrom str)
        else Error "Derived from has a maximum length of 1024 characters"

type ShortStringType = private ShortStringType of string
    with
    static member create (str: string) =
        if str.Length <= 256
        then Ok (ShortStringType str)
        else Error "Short String Type has a maximum length of 256 characters"

/// The version number of the DES.
type DESVersion = ShortStringType

/// Country or Org trigraph/tetragraph
type RelTo = RelTo of string

/// The set of countries and/or	international organizations associated with a “Display Only To”	marking
/// todo limit to 1000 values
type DisplayOnlyTo = RelTo list

type DisseminationControl =
    | RS
    | FOUO
    | OC
    | ``OC-USGOV``
    | IMC
    | NF
    | PR
    | REL
    | RELIDO
    | EYES
    | DSEN
    | FISA
    | DISPLAYONLY
    with
    member this.description =
        match this with
        | RS -> "RISK SENSITIVE"
        | FOUO -> "FOR OFFICIAL USE ONLY"
        | OC -> "ORIGINATOR CONTROLLED"
        | ``OC-USGOV`` -> "ORIGINATOR CONTROLLED US GOVERNMENT"
        | IMC -> "CONTROLLED IMAGERY"
        | NF -> "NOT RELEASABLE TO FOREIGN NATIONALS"
        | PR -> "CAUTION-PROPRIETARY INFORMATION INVOLVED"
        | REL -> "AUTHORIZED FOR RELEASE TO"
        | RELIDO -> "RELEASABLE BY INFORMATION DISCLOSURE OFFICIAL"
        | EYES -> "EYES ONLY"
        | DSEN -> "DEA SENSITIVE"
        | FISA -> "FOREIGN INTELLIGENCE SURVEILLANCE ACT"
        | DISPLAYONLY -> "AUTHORIZED FOR DISPLAY BUT NOT RELEASE TO"

/// Applicable dissemination control markings for a document or portion
/// todo limit to 13 values
type DisseminationControls = DisseminationControl list

/// An indicator that an element’s ISM attributes do not contribute to the “rollup” classification of the document
[<RequireQualifiedAccess>]
type ExcludeFromRollup =
    | Yes
    | No

type Exemptions =
    | IC_710_MANDATORY_FDR
    | DOD_DISTRO_STATEMENT

/// Specific exemptions within an ISM rule set that are claimed for a document
/// todo limit to 2 values
type ExemptFrom = Exemptions list

/// Country or Org trigraph/tetragraph
type SourceOpen = SourceOpen of string

/// The set of countries and/or international organizations whose information is derivatively sourced in a
/// document when the source of the information is not concealed (also used for cases when the source is unknown)
/// todo limit to 1000 values
type FGISourceOpen = SourceOpen list

/// Country or Org trigraph/tetragraph or FGI
type SourceProtected = SourceProtected of string

/// The set of countries and/or international organizations whose information is derivatively sourced in a
/// document when the source of the information must be concealed
/// todo limit to 1000 values
type FGISourceProtected = SourceProtected list

/// When true, indicates the ISM markings specified are estimated (e.g. system high).
[<RequireQualifiedAccess>]
type HasApproximateMarkings =
    | Yes
    | No

/// The version number of the ISMCAT CES used in the document
type ISMCatCesVersion = ShortStringType

/// A long string, less than or equal to 32000 characters.
type LongStringType = private LongStringType of string
    with
    static member create (str: string) =
        if str.Length <= 32000
        then Ok (LongStringType str)
        else Error "Long String Type has a maximum length of 32000 characters"

type OwnerProducer = OwnerProducer of string

/// The set of national governments and/or international organizations that have purview over the
/// containing classification marking
/// todo limit to 1000 values
type OwnerProducers = OwnerProducer list

/// When true, an indicator that entities in the @ism:ownerProducer attribute are JOINT owners of the data
[<RequireQualifiedAccess>]
type Joint =
    | Yes
    | No

type SCIControl =
    | HCS
    | ``HCS-O``
    | ``HCS-P``
    | RSV
    | SI
    | ``SI-EU``
    | ``SI-G``
    | ``SI-NK``
    | ``TK``
    | ``TK-BLFH``
    | ``TK-IDIT``
    | ``TK-KAND``

/// This attribute is used at both the resource and the portion levels. One or more indicators identifying
/// sensitive compartmented information control system(s). It is manifested in portion marks and security banners.
/// PERMISSIBLE VALUES The permissible values for this attribute are defined in the Controlled Value Enumeration:
/// CVEnumISMSCIControls.xml
/// todo limit to 12 values
type SCIControls = SCIControl list

type SARValue = SARValue of string

/// This attribute is used at both the resource and the portion levels. One or more indicators identifying the
/// defense or intelligence programs for which special access is required. It is manifested in portion marks and
/// security banners. PERMISSIBLE VALUES The permissible values for this attribute are defined in the Controlled Value
/// Enumeration: CVEnumISMSAR.xml
type SARIdentifier = SARValue list

type NonICMarking =
    | DS
    | XD
    | ND
    | SBU
    | ``SBU-NF``
    | LES
    | ``LES-NF``
    | SSI
    | NNPI

/// One or more indicators of an expansion or limitation on the distribution of a document or portion originating
/// from non-intelligence components
type NonICMarkings = NonICMarking list

type NonUSControl =
    | ATOMAL
    | BOHEMIA
    | BALK

/// One or more indicators of an expansion or limitation on the distribution of a document or portion originating
/// from non-US components (foreign government or international organization).
type NonUSControls = NonUSControl list

/// The group of Information Security Marking attributes in which the use of attributes 'classification' and
/// 'ownerProducer' is required.
type SecurityAttributesGroup =
    abstract Classification: Classification // required
    abstract OwnerProducer: OwnerProducer * OwnerProducers // required
    abstract Joint: Joint option
    abstract SCIControls: SCIControl list
    abstract SARIdentifier: SARValue list
    abstract AtomicEnergyMarkings: AtomicEnergyMarking list
    abstract DisseminationControls: DisseminationControl list
    abstract DisplayOnlyTo: RelTo list
    abstract FGISourceOpen: SourceOpen list
    abstract FGISourceProtected: SourceProtected list
    abstract ReleasableTo: RelTo list
    abstract NonICMarkings: NonICMarking list
    abstract ClassifiedBy: ClassifiedBy option
    abstract CompilationReason: CompilationReason option
    abstract DerivativelyClassifiedBy: DerivativelyClassifiedBy option
    abstract ClassificationReason: ClassificationReason option
    abstract NonUSControls: NonUSControl list
    abstract DerivedFrom: DerivedFrom option
    abstract DeclassDate: DeclassDate option
    abstract DeclassEvent: DeclassEvent option
    abstract DeclassException: DeclassException option
    abstract HasApproximateMarkings: HasApproximateMarkings option

/// The group of Information Security Marking attributes in which the use of attributes 'classification' and
/// 'ownerProducer' is optional. This group is to be contrasted with group 'SecurityAttributesGroup' in which
/// use of these attributes is required.
type SecurityAttributesOptionGroup =
    abstract Classification: Classification option
    abstract OwnerProducer: OwnerProducers
    abstract Joint: Joint option
    abstract SCIControls: SCIControl list
    abstract SARIdentifier: SARValue list
    abstract AtomicEnergyMarkings: AtomicEnergyMarking list
    abstract DisseminationControls: DisseminationControl list
    abstract DisplayOnlyTo: RelTo list
    abstract FGISourceOpen: SourceOpen list
    abstract FGISourceProtected: SourceProtected list
    abstract ReleasableTo: RelTo list
    abstract NonICMarkings: NonICMarking list
    abstract ClassifiedBy: ClassifiedBy option
    abstract CompilationReason: CompilationReason option
    abstract DerivativelyClassifiedBy: DerivativelyClassifiedBy option
    abstract ClassificationReason: ClassificationReason option
    abstract NonUSControls: NonUSControl list
    abstract DerivedFrom: DerivedFrom option
    abstract DeclassDate: DeclassDate option
    abstract DeclassEvent: DeclassEvent option
    abstract DeclassException: DeclassException option
    abstract HasApproximateMarkings: HasApproximateMarkings option

type LongStringWithSecurityType =
    inherit SecurityAttributesGroup
    abstract Value: LongStringType

/// Indicates that the element specifies a point-of-contact (POC) and the methods with which to contact that
/// individual. As certain POCs are required for different reasons (ICD-710 compliance, DoD Distribution statements,
/// etc), the values for this attribute specify the reason(s) why the POC is provided.
type PocType =
    | ``ICD-710``
    | ``DoD-Dist-B``
    | ``DoD-Dist-C``
    | ``DoD-Dist-D``
    | ``DoD-Dist-E``
    | ``DoD-Dist-F``
    | ``DoD-Dist-X``

/// An attribute group to be used on the element that represents an entity that can be designated as a
/// point-of-contact. This node may be a single person or an organization.
type POCAttributeGroup =
    abstract PocType : PocType list

/// The actual text of a notice.
type NoticeText =
    inherit LongStringWithSecurityType
    inherit POCAttributeGroup

type NoticeBaseType =
    abstract NoticeTexts: NoticeText * NoticeText list

type NoticeTypeT =
    inherit NoticeBaseType

/// An indicator that the
/// containing element contains a security-related notice. This attribute is used to
/// categorize which of the required notices is specified in the element. These
/// categories include those described in the Intelligence Community Markings System
/// Register and Manual, as well as additional well-defined and formally recognized
/// security notice types described in other directives, such as US-Person and DoD
/// Distribution. The element could contain any structure that the implementing
/// schema defines, and rendering details are relegated to the implementing schema.
/// The permissible values for this attribute are defined in the ISM Notice CVE:
/// CVEnumISMNotice.xml
type NoticeType =
    | FISA
    | IMC
    | CNWDI
    | RD
    | FRD
    | DS
    | LES
    | ``LES-NF``
    | DSEN
    | ``DoD-Dist-A``
    | ``DoD-Dist-B``
    | ``DoD-Dist-C``
    | ``DoD-Dist-D``
    | ``DoD-Dist-E``
    | ``DoD-Dist-F``
    | ``DoD-Dist-X``
    | ``US-Person``
    | Pre13526ORCON
    | POC
    | COMSEC
    | SSI
    | RSEN

type NoticeReason = private NoticeReason of string
    with
    static member create (str: string) =
        if str.Length <= 2048
        then Ok (NoticeReason str)
        else Error "Notice reason has a maximum length of 2048 characters"

//type ISMNoticeBaseAttributeGroup =
//    abstract NoticeType: NoticeType list
//    abstract NoticeReason: NoticeReason option
//    abstract NoticeDate: NoticeDate option
//    abstract UnregisteredNoticeType: UnregisteredNoticeType option