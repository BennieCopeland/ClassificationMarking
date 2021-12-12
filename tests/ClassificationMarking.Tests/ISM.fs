module ClassificationMarking.Tests.ISM

open FsToolkit.ErrorHandling
open NodaTime
open FsCheck
open FsCheck.Xunit
open NodaTime

type Designator =
    | Restricted
    | Confidential
    | Secret
    | TopSecret

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

type DeclassifyOn =
    | Date of LocalDate
    | Event of DeclassEvent
    | Exception of DeclassException

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

//type OriginalClassification =
//    {
//        
//    }
//
//type DerivativeClassification =
//    {
//        
//    }

type ClassificationAuthorityBlock =
    {
        ClassificationReason: ClassificationReason option
        ClassifiedBy: ClassifiedBy option
        DeclassifyOn: DeclassifyOn option
        DerivativelyClassifiedBy: DerivativelyClassifiedBy option
        DerivedFrom: DerivedFrom option
    }

type Classified =
    {
        CreateDate : LocalDate
        Designator : Designator
        AtomicEnergyMarkings : AtomicEnergyMarking list
        ClassificationAuthorityBlock : ClassificationAuthorityBlock
    }

type Classification =
    | Unclassified
    | Classified of Classified

type Resource = Resource of Classification









let createResource classifications createDate =
    let declassifyOn =
        DeclassEvent.create ""
        |> Result.defaultWith (fun () -> failwith "Blah")
    
    {
        CreateDate = LocalDate(2021, 8, 30)
        Designator = Secret
        AtomicEnergyMarkings = []
        ClassificationAuthorityBlock = {
            ClassificationReason = None
            ClassifiedBy= None
            DeclassifyOn = Some (Event declassifyOn)
            DerivativelyClassifiedBy = None
            DerivedFrom = None
        }
    }
    |> Classified
    |> Resource

module LocalDate =
    let generator =
        gen {
            let! year = Gen.choose (1990, 2050)
            let! month = Gen.choose (1, 12)
            
            let maxDay =
                match month with
                | 2 ->
                    if year % 400 = 0 || year % 4 = 0
                    then 28
                    else 27
                | 1 | 3 | 5 | 7 | 8 | 10 | 12 -> 31
                | _ -> 30
            
            let! day = Gen.choose (1, maxDay)
            
            return LocalDate(year, month, day)
        }

type Generator =
    static member LocalDate() = Arb.fromGen (LocalDate.generator)

type ISMPropertyAttribute () =
    inherit PropertyAttribute(Arbitrary = [| typeof<Generator> |])

// USDOD
[<ISMProperty>]
let ``ISM_ID_00155.sch`` () = false

[<Property>]
let ``ISM_ID_00157.sch`` () = false

[<Property>]
let ``ISM_ID_00158.sch`` () = false

[<Property>]
let ``ISM_ID_00161.sch`` () = false

[<Property>]
let ``ISM_ID_00162.sch`` () = false

[<Property>]
let ``ISM_ID_00227.sch`` () = false

[<Property>]
let ``ISM_ID_00237.sch`` () = false

[<Property>]
let ``ISM_ID_00238.sch`` () = false

[<Property>]
let ``ISM_ID_00239.sch`` () = false

[<Property>]
let ``ISM_ID_00240.sch`` () = false

let is_ISM_NSI_EO_APPLIES (Resource resource) (classifications: Classification list) =
    let isUnclassified designator =
        match designator with
        | Unclassified -> true
        | _ -> false
    
    match resource with
    | Classified classified ->
        classified.CreateDate >= LocalDate(1996, 4, 11)
        && classifications |> List.exists (fun c ->
            match c with
            | Classified classified -> List.isEmpty classified.AtomicEnergyMarkings
            | _ -> false)
    | _ -> false


let hasDeclassifySet (Resource resource) =
    match resource with
    | Classified classified ->
        Option.isSome classified.ClassificationAuthorityBlock.DeclassifyOn
    | _ -> false

// USGov
[<ISMProperty>]
let ``[ISM_ID_00014] Documents under E.O. 13526 must have declassification instructions included in the classification authority block information.`` (classifications: Classification list) =
    let createDate = LocalDate(2021, 08, 30)
    
    let output = createResource classifications createDate
    
    is_ISM_NSI_EO_APPLIES output classifications ==>
    (output |> hasDeclassifySet)


[<ISMProperty>]
let ``[ISM_ID_00016] If the document is an ISM_USGOV_RESOURCE, unclassified markings will not have CAB data, SAR Identifiers of SCI Controls `` () =
    // encoded into the type system
    true

[<ISMProperty>]
let ``[ISM_ID_00017] Documents under E.O. 13526 containing Originally Classified data require a classification reason to be identified.`` () =
    false

[<Property>]
let ``ISM_ID_00026.sch`` () = false

[<Property>]
let ``ISM_ID_00028.sch`` () = false

[<Property>]
let ``ISM_ID_00030.sch`` () = false

[<Property>]
let ``ISM_ID_00031.sch`` () = false

[<Property>]
let ``ISM_ID_00032.sch`` () = false

[<Property>]
let ``ISM_ID_00033.sch`` () = false

[<Property>]
let ``ISM_ID_00035.sch`` () = false

[<Property>]
let ``ISM_ID_00037.sch`` () = false

[<Property>]
let ``ISM_ID_00038.sch`` () = false

[<Property>]
let ``ISM_ID_00040.sch`` () = false

[<Property>]
let ``ISM_ID_00041.sch`` () = false

[<Property>]
let ``ISM_ID_00042.sch`` () = false

[<Property>]
let ``ISM_ID_00043.sch`` () = false

[<Property>]
let ``ISM_ID_00044.sch`` () = false

[<Property>]
let ``ISM_ID_00045.sch`` () = false

[<Property>]
let ``ISM_ID_00047.sch`` () = false

[<Property>]
let ``ISM_ID_00048.sch`` () = false

[<Property>]
let ``ISM_ID_00049.sch`` () = false

[<Property>]
let ``ISM_ID_00056.sch`` () = false

[<Property>]
let ``ISM_ID_00058.sch`` () = false

[<Property>]
let ``ISM_ID_00059.sch`` () = false

[<Property>]
let ``ISM_ID_00064.sch`` () = false

[<Property>]
let ``ISM_ID_00065.sch`` () = false

[<Property>]
let ``ISM_ID_00066.sch`` () = false

[<Property>]
let ``ISM_ID_00067.sch`` () = false

[<Property>]
let ``ISM_ID_00068.sch`` () = false

[<Property>]
let ``ISM_ID_00070.sch`` () = false

[<Property>]
let ``ISM_ID_00071.sch`` () = false

[<Property>]
let ``ISM_ID_00072.sch`` () = false

[<Property>]
let ``ISM_ID_00073.sch`` () = false

[<Property>]
let ``ISM_ID_00074.sch`` () = false

[<Property>]
let ``ISM_ID_00075.sch`` () = false

[<Property>]
let ``ISM_ID_00077.sch`` () = false

[<Property>]
let ``ISM_ID_00078.sch`` () = false

[<Property>]
let ``ISM_ID_00079.sch`` () = false

[<Property>]
let ``ISM_ID_00080.sch`` () = false

[<Property>]
let ``ISM_ID_00081.sch`` () = false

[<Property>]
let ``ISM_ID_00084.sch`` () = false

[<Property>]
let ``ISM_ID_00085.sch`` () = false

[<Property>]
let ``ISM_ID_00086.sch`` () = false

[<Property>]
let ``ISM_ID_00087.sch`` () = false

[<Property>]
let ``ISM_ID_00088.sch`` () = false

[<Property>]
let ``ISM_ID_00090.sch`` () = false

[<Property>]
let ``ISM_ID_00095.sch`` () = false

[<Property>]
let ``ISM_ID_00096.sch`` () = false

[<Property>]
let ``ISM_ID_00097.sch`` () = false

[<Property>]
let ``ISM_ID_00099.sch`` () = false

[<Property>]
let ``ISM_ID_00100.sch`` () = false

[<Property>]
let ``ISM_ID_00104.sch`` () = false

[<Property>]
let ``ISM_ID_00105.sch`` () = false

[<Property>]
let ``ISM_ID_00107.sch`` () = false

[<Property>]
let ``ISM_ID_00108.sch`` () = false

[<Property>]
let ``ISM_ID_00109.sch`` () = false

[<Property>]
let ``ISM_ID_00110.sch`` () = false

[<Property>]
let ``ISM_ID_00121.sch`` () = false

[<Property>]
let ``ISM_ID_00124.sch`` () = false

[<Property>]
let ``ISM_ID_00127.sch`` () = false

[<Property>]
let ``ISM_ID_00128.sch`` () = false

[<Property>]
let ``ISM_ID_00129.sch`` () = false

[<Property>]
let ``ISM_ID_00130.sch`` () = false

[<Property>]
let ``ISM_ID_00132.sch`` () = false

[<Property>]
let ``ISM_ID_00133.sch`` () = false

[<Property>]
let ``ISM_ID_00134.sch`` () = false

[<Property>]
let ``ISM_ID_00135.sch`` () = false

[<Property>]
let ``ISM_ID_00136.sch`` () = false

[<Property>]
let ``ISM_ID_00137.sch`` () = false

[<Property>]
let ``ISM_ID_00138.sch`` () = false

[<Property>]
let ``ISM_ID_00139.sch`` () = false

[<Property>]
let ``ISM_ID_00141.sch`` () = false

[<Property>]
let ``ISM_ID_00142.sch`` () = false

[<Property>]
let ``ISM_ID_00143.sch`` () = false

[<Property>]
let ``ISM_ID_00145.sch`` () = false

[<Property>]
let ``ISM_ID_00146.sch`` () = false

[<Property>]
let ``ISM_ID_00147.sch`` () = false

[<Property>]
let ``ISM_ID_00148.sch`` () = false

[<Property>]
let ``ISM_ID_00149.sch`` () = false

[<Property>]
let ``ISM_ID_00150.sch`` () = false

[<Property>]
let ``ISM_ID_00151.sch`` () = false

[<Property>]
let ``ISM_ID_00152.sch`` () = false

[<Property>]
let ``ISM_ID_00153.sch`` () = false

[<Property>]
let ``ISM_ID_00154.sch`` () = false

[<Property>]
let ``ISM_ID_00159.sch`` () = false

[<Property>]
let ``ISM_ID_00164.sch`` () = false

[<Property>]
let ``ISM_ID_00165.sch`` () = false

[<Property>]
let ``ISM_ID_00166.sch`` () = false

[<Property>]
let ``ISM_ID_00167.sch`` () = false

[<Property>]
let ``ISM_ID_00168.sch`` () = false

[<Property>]
let ``ISM_ID_00169.sch`` () = false

[<Property>]
let ``ISM_ID_00170.sch`` () = false

[<Property>]
let ``ISM_ID_00173.sch`` () = false

[<Property>]
let ``ISM_ID_00174.sch`` () = false

[<Property>]
let ``ISM_ID_00175.sch`` () = false

[<Property>]
let ``ISM_ID_00176.sch`` () = false

[<Property>]
let ``ISM_ID_00178.sch`` () = false

[<Property>]
let ``ISM_ID_00179.sch`` () = false

[<Property>]
let ``ISM_ID_00180.sch`` () = false

[<Property>]
let ``ISM_ID_00181.sch`` () = false

[<Property>]
let ``ISM_ID_00183.sch`` () = false

[<Property>]
let ``ISM_ID_00184.sch`` () = false

[<Property>]
let ``ISM_ID_00185.sch`` () = false

[<Property>]
let ``ISM_ID_00186.sch`` () = false

[<Property>]
let ``ISM_ID_00187.sch`` () = false

[<Property>]
let ``ISM_ID_00188.sch`` () = false

[<Property>]
let ``ISM_ID_00189.sch`` () = false

[<Property>]
let ``ISM_ID_00190.sch`` () = false

[<Property>]
let ``ISM_ID_00191.sch`` () = false

[<Property>]
let ``ISM_ID_00192.sch`` () = false

[<Property>]
let ``ISM_ID_00193.sch`` () = false

[<Property>]
let ``ISM_ID_00196.sch`` () = false

[<Property>]
let ``ISM_ID_00197.sch`` () = false

[<Property>]
let ``ISM_ID_00198.sch`` () = false

[<Property>]
let ``ISM_ID_00199.sch`` () = false

[<Property>]
let ``ISM_ID_00200.sch`` () = false

[<Property>]
let ``ISM_ID_00201.sch`` () = false

[<Property>]
let ``ISM_ID_00202.sch`` () = false

[<Property>]
let ``ISM_ID_00203.sch`` () = false

[<Property>]
let ``ISM_ID_00204.sch`` () = false

[<Property>]
let ``ISM_ID_00205.sch`` () = false

[<Property>]
let ``ISM_ID_00206.sch`` () = false

[<Property>]
let ``ISM_ID_00207.sch`` () = false

[<Property>]
let ``ISM_ID_00208.sch`` () = false

[<Property>]
let ``ISM_ID_00209.sch`` () = false

[<Property>]
let ``ISM_ID_00210.sch`` () = false

[<Property>]
let ``ISM_ID_00211.sch`` () = false

[<Property>]
let ``ISM_ID_00213.sch`` () = false

[<Property>]
let ``ISM_ID_00214.sch`` () = false

[<Property>]
let ``ISM_ID_00217.sch`` () = false

[<Property>]
let ``ISM_ID_00219.sch`` () = false

[<Property>]
let ``ISM_ID_00221.sch`` () = false

[<Property>]
let ``ISM_ID_00223.sch`` () = false

[<Property>]
let ``ISM_ID_00226.sch`` () = false

[<Property>]
let ``ISM_ID_00228.sch`` () = false

[<Property>]
let ``ISM_ID_00229.sch`` () = false

[<Property>]
let ``ISM_ID_00230.sch`` () = false

[<Property>]
let ``ISM_ID_00231.sch`` () = false

[<Property>]
let ``ISM_ID_00241.sch`` () = false

[<Property>]
let ``ISM_ID_00242.sch`` () = false

[<Property>]
let ``ISM_ID_00243.sch`` () = false

[<Property>]
let ``ISM_ID_00244.sch`` () = false

[<Property>]
let ``ISM_ID_00245.sch`` () = false

[<Property>]
let ``ISM_ID_00246.sch`` () = false

[<Property>]
let ``ISM_ID_00250.sch`` () = false

[<Property>]
let ``ISM_ID_00252.sch`` () = false

[<Property>]
let ``ISM_ID_00253.sch`` () = false

[<Property>]
let ``ISM_ID_00254.sch`` () = false

[<Property>]
let ``ISM_ID_00255.sch`` () = false

[<Property>]
let ``ISM_ID_00256.sch`` () = false

[<Property>]
let ``ISM_ID_00257.sch`` () = false

[<Property>]
let ``ISM_ID_00258.sch`` () = false

[<Property>]
let ``ISM_ID_00259.sch`` () = false

[<Property>]
let ``ISM_ID_00260.sch`` () = false

[<Property>]
let ``ISM_ID_00261.sch`` () = false

[<Property>]
let ``ISM_ID_00262.sch`` () = false

[<Property>]
let ``ISM_ID_00263.sch`` () = false

[<Property>]
let ``ISM_ID_00264.sch`` () = false

[<Property>]
let ``ISM_ID_00265.sch`` () = false

[<Property>]
let ``ISM_ID_00266.sch`` () = false

[<Property>]
let ``ISM_ID_00267.sch`` () = false

[<Property>]
let ``ISM_ID_00268.sch`` () = false

[<Property>]
let ``ISM_ID_00269.sch`` () = false

[<Property>]
let ``ISM_ID_00270.sch`` () = false

[<Property>]
let ``ISM_ID_00271.sch`` () = false

[<Property>]
let ``ISM_ID_00272.sch`` () = false

[<Property>]
let ``ISM_ID_00273.sch`` () = false

[<Property>]
let ``ISM_ID_00274.sch`` () = false

[<Property>]
let ``ISM_ID_00275.sch`` () = false

[<Property>]
let ``ISM_ID_00276.sch`` () = false

[<Property>]
let ``ISM_ID_00277.sch`` () = false

[<Property>]
let ``ISM_ID_00278.sch`` () = false

[<Property>]
let ``ISM_ID_00279.sch`` () = false

[<Property>]
let ``ISM_ID_00280.sch`` () = false

[<Property>]
let ``ISM_ID_00281.sch`` () = false

[<Property>]
let ``ISM_ID_00282.sch`` () = false

[<Property>]
let ``ISM_ID_00283.sch`` () = false

[<Property>]
let ``ISM_ID_00284.sch`` () = false

[<Property>]
let ``ISM_ID_00285.sch`` () = false

[<Property>]
let ``ISM_ID_00286.sch`` () = false

[<Property>]
let ``ISM_ID_00287.sch`` () = false

[<Property>]
let ``ISM_ID_00288.sch`` () = false

[<Property>]
let ``ISM_ID_00289.sch`` () = false

[<Property>]
let ``ISM_ID_00290.sch`` () = false

[<Property>]
let ``ISM_ID_00291.sch`` () = false

[<Property>]
let ``ISM_ID_00292.sch`` () = false

[<Property>]
let ``ISM_ID_00293.sch`` () = false

[<Property>]
let ``ISM_ID_00294.sch`` () = false

[<Property>]
let ``ISM_ID_00295.sch`` () = false

[<Property>]
let ``ISM_ID_00296.sch`` () = false

[<Property>]
let ``ISM_ID_00297.sch`` () = false

[<Property>]
let ``ISM_ID_00298.sch`` () = false

[<Property>]
let ``ISM_ID_00299.sch`` () = false

[<Property>]
let ``ISM_ID_00302.sch`` () = false

[<Property>]
let ``ISM_ID_00303.sch`` () = false

[<Property>]
let ``ISM_ID_00304.sch`` () = false

[<Property>]
let ``ISM_ID_00305.sch`` () = false

[<Property>]
let ``ISM_ID_00306.sch`` () = false

[<Property>]
let ``ISM_ID_00307.sch`` () = false

[<Property>]
let ``ISM_ID_00308.sch`` () = false

[<Property>]
let ``ISM_ID_00309.sch`` () = false

[<Property>]
let ``ISM_ID_00310.sch`` () = false

[<Property>]
let ``ISM_ID_00311.sch`` () = false

[<Property>]
let ``ISM_ID_00313.sch`` () = false

[<Property>]
let ``ISM_ID_00314.sch`` () = false

[<Property>]
let ``ISM_ID_00315.sch`` () = false

[<Property>]
let ``ISM_ID_00316.sch`` () = false

[<Property>]
let ``ISM_ID_00317.sch`` () = false

[<Property>]
let ``ISM_ID_00318.sch`` () = false

[<Property>]
let ``ISM_ID_00319.sch`` () = false

[<Property>]
let ``ISM_ID_00320.sch`` () = false

[<Property>]
let ``ISM_ID_00321.sch`` () = false

[<Property>]
let ``ISM_ID_00324.sch`` () = false

[<Property>]
let ``ISM_ID_00325.sch`` () = false

[<Property>]
let ``ISM_ID_00326.sch`` () = false

[<Property>]
let ``ISM_ID_00327.sch`` () = false

[<Property>]
let ``ISM_ID_00328.sch`` () = false

[<Property>]
let ``ISM_ID_00329.sch`` () = false

[<Property>]
let ``ISM_ID_00330.sch`` () = false

[<Property>]
let ``ISM_ID_00331.sch`` () = false

[<Property>]
let ``ISM_ID_00332.sch`` () = false

[<Property>]
let ``ISM_ID_00333.sch`` () = false

[<Property>]
let ``ISM_ID_00335.sch`` () = false

[<Property>]
let ``ISM_ID_00336.sch`` () = false

[<Property>]
let ``ISM_ID_00341.sch`` () = false

[<Property>]
let ``ISM_ID_00343.sch`` () = false

[<Property>]
let ``ISM_ID_00344.sch`` () = false

[<Property>]
let ``ISM_ID_00345.sch`` () = false

[<Property>]
let ``ISM_ID_00346.sch`` () = false

[<Property>]
let ``ISM_ID_00347.sch`` () = false

[<Property>]
let ``ISM_ID_00348.sch`` () = false

[<Property>]
let ``ISM_ID_00349.sch`` () = false

[<Property>]
let ``ISM_ID_00350.sch`` () = false

[<Property>]
let ``ISM_ID_00351.sch`` () = false

[<Property>]
let ``ISM_ID_00352.sch`` () = false

[<Property>]
let ``ISM_ID_00353.sch`` () = false

[<Property>]
let ``ISM_ID_00354.sch`` () = false

[<Property>]
let ``ISM_ID_00355.sch`` () = false

[<Property>]
let ``ISM_ID_00356.sch`` () = false

[<Property>]
let ``ISM_ID_00357.sch`` () = false

[<Property>]
let ``ISM_ID_00361.sch`` () = false

[<Property>]
let ``ISM_ID_00362.sch`` () = false

[<Property>]
let ``ISM_ID_00363.sch`` () = false

[<Property>]
let ``ISM_ID_00364.sch`` () = false

[<Property>]
let ``ISM_ID_00365.sch`` () = false

[<Property>]
let ``ISM_ID_00367.sch`` () = false

[<Property>]
let ``ISM_ID_00368.sch`` () = false

[<Property>]
let ``ISM_ID_00369.sch`` () = false

[<Property>]
let ``ISM_ID_00370.sch`` () = false

[<Property>]
let ``ISM_ID_00371.sch`` () = false

[<Property>]
let ``ISM_ID_00372.sch`` () = false

[<Property>]
let ``ISM_ID_00373.sch`` () = false

[<Property>]
let ``ISM_ID_00374.sch`` () = false

[<Property>]
let ``ISM_ID_00379.sch`` () = false

[<Property>]
let ``ISM_ID_00380.sch`` () = false


// USIC
[<Property>]
let ``ISM_ID_00119.sch`` () = false

[<Property>]
let ``ISM_ID_00225.sch`` () = false

[<Property>]
let ``ISM_ID_00251.sch`` () = false

// General

[<Property>]
let ``[ISM-ID-00002][Error] For every attribute in the ISM namespace that is used in a document a non-null value must be present.`` () =
    // Not applicable
    true

[<Property>]
let ``ISM_ID_00012.sch`` () = false

[<Property>]
let ``ISM_ID_00102.sch`` () = false

[<Property>]
let ``ISM_ID_00103.sch`` () = false

[<Property>]
let ``ISM_ID_00118.sch`` () = false

[<Property>]
let ``ISM_ID_00125.sch`` () = false

[<Property>]
let ``ISM_ID_00163.sch`` () = false

[<Property>]
let ``ISM_ID_00194.sch`` () = false

[<Property>]
let ``ISM_ID_00195.sch`` () = false

[<Property>]
let ``ISM_ID_00236.sch`` () = false

[<Property>]
let ``ISM_ID_00248.sch`` () = false

[<Property>]
let ``ISM_ID_00300.sch`` () = false

[<Property>]
let ``ISM_ID_00322.sch`` () = false

[<Property>]
let ``ISM_ID_00323.sch`` () = false

[<Property>]
let ``ISM_ID_00337.sch`` () = false

[<Property>]
let ``ISM_ID_00338.sch`` () = false

[<Property>]
let ``ISM_ID_00339.sch`` () = false

[<Property>]
let ``ISM_ID_00340.sch`` () = false

[<Property>]
let ``ISM_ID_00358.sch`` () = false

[<Property>]
let ``ISM_ID_00359.sch`` () = false

[<Property>]
let ``ISM_ID_00360.sch`` () = false

[<Property>]
let ``ISM_ID_00366.sch`` () = false

[<Property>]
let ``ISM_ID_00375.sch`` () = false

[<Property>]
let ``ISM_ID_00376.sch`` () = false

[<Property>]
let ``ISM_ID_00377.sch`` () = false

[<Property>]
let ``ISM_ID_00378.sch`` () = false

[<Property>]
let ``ISM_ID_00381.sch`` () = false
