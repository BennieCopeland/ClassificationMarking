module Common

open FsCheck
open FsCheck.Xunit
open Types
open System.Text.RegularExpressions

let shrink validator t =
        Arb.Default.Derive().Shrinker t
        |> Seq.filter validator

type AlphaString = AlphaString of string with
    static member op_Explicit(AlphaString str) = str
    
    static member validCharacters =
        [ 'A'; 'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'; 'I'; 'J'; 'K'; 'L'; 'M';
          'N'; 'O'; 'P'; 'Q'; 'R'; 'S'; 'T'; 'U'; 'V'; 'W'; 'X'; 'Y'; 'Z' ]
    
    static member generator =
        Gen.sized <| fun n ->
            Gen.elements AlphaString.validCharacters
            |> Gen.listOfLength n
            |> Gen.map Array.ofList
            |> Gen.map (fun (chars:char[]) -> System.String(chars))
    
    static member valid (AlphaString str) =
        str
        |> Seq.forall (fun a -> List.contains a AlphaString.validCharacters)
    
    static member shrink = shrink AlphaString.valid

type TrigraphSizedString = TrigraphSizedString of string with
    static member op_Explicit(TrigraphSizedString str) = str
    
    static member generator =
        Gen.resize 3 AlphaString.generator
        |> Gen.map TrigraphSizedString
    
    static member valid (TrigraphSizedString str) =
        str.Length = 3 && AlphaString.valid (AlphaString str)
    
    static member shrink = shrink TrigraphSizedString.valid

type NonTrigraphSizedString = NonTrigraphSizedString of string with
    static member op_Explicit(NonTrigraphSizedString str) = str
    
    static member generator =
        Gen.sized <| fun n ->
            let n' = if n < 4 then 4 else n
            
            let alphaStringBetween range =
                gen {
                    let! size = Gen.choose range
                    return! Gen.resize size AlphaString.generator
                }
            
            [
                alphaStringBetween (0, 2)
                alphaStringBetween (4, n')
            ]
            |> Gen.oneof
            |> Gen.map NonTrigraphSizedString
    
    static member valid (NonTrigraphSizedString str) =
        str.Length <> 3 || not <| AlphaString.valid (AlphaString str)
    
    static member shrink = shrink NonTrigraphSizedString.valid

type TetragraphSizedString = TetragraphSizedString of string with
    static member op_Explicit(TetragraphSizedString str) = str
    
    static member generator =
        Gen.resize 4 AlphaString.generator
        |> Gen.map TetragraphSizedString
    
    static member valid (TetragraphSizedString str) =
        str.Length = 4 && AlphaString.valid (AlphaString str)
    
    static member shrink = shrink TetragraphSizedString.valid

type NonTetragraphSizedString = NonTetragraphSizedString of string with
    static member op_Explicit(NonTetragraphSizedString str) = str
    
    static member generator =
        Gen.sized <| fun n ->
            let n' = if n < 5 then 5 else n
            
            let alphaStringBetween range =
                gen {
                    let! size = Gen.choose range
                    return! Gen.resize size AlphaString.generator
                }
            
            [
                alphaStringBetween (0, 3)
                alphaStringBetween (5, n')
            ]
            |> Gen.oneof
            |> Gen.map NonTetragraphSizedString
    
    static member valid (NonTetragraphSizedString str) =
        str.Length <> 4 || not <| AlphaString.valid (AlphaString str)
    
    static member shrink = shrink NonTetragraphSizedString.valid


type CountryCodeSizedString = CountryCodeSizedString of string with
    static member  op_Explicit(CountryCodeSizedString str ) = str
    
    static member generator =
        [
            TrigraphSizedString.generator |> Gen.map (fun (TrigraphSizedString s) -> s)
            TetragraphSizedString.generator |> Gen.map (fun (TetragraphSizedString s) -> s)
        ]
        |> Gen.oneof
        |> Gen.map CountryCodeSizedString
    
    static member valid (CountryCodeSizedString str) =
        TrigraphSizedString.valid (TrigraphSizedString str) || TetragraphSizedString.valid (TetragraphSizedString str)
    
    static member shrink = shrink CountryCodeSizedString.valid

type NonCountryCodeSizedString = NonCountryCodeSizedString of string with
    static member  op_Explicit(NonCountryCodeSizedString str ) = str
    
    static member generator =
        Gen.sized <| fun n ->
            let n' = if n < 5 then 5 else n
            
            let undersized =
                gen {
                    let! size = Gen.choose (0, 2)
                    return! Gen.resize size AlphaString.generator
                }
                    
            let overSized =
                gen {
                    let! size = Gen.choose (5, n')
                    return! Gen.resize size AlphaString.generator
                }
            
            [
                undersized
                overSized
            ]
            |> Gen.oneof
            |> Gen.map NonCountryCodeSizedString
    
    static member valid (NonCountryCodeSizedString str) =
        not <| TrigraphSizedString.valid (TrigraphSizedString str) &&
        not <| TetragraphSizedString.valid (TetragraphSizedString str)
    
    static member shrink = shrink NonCountryCodeSizedString.valid

module CountryCode =
    let generator =
        CountryCodeSizedString.generator
        |> Gen.map (fun (CountryCodeSizedString s) -> s)
        |> Gen.map CountryCode.tryCreate
        |> Gen.map (fun countryCode ->
            match countryCode with
            | Ok countryCode -> countryCode
            | Error CountryCodeError.InvalidLength -> failwith "Error generating Country Code in generator due to invalid length"
            | Error CountryCodeError.NullString -> failwith "Error generating Country Code in generator due to null value"
            )
    
    let valid (countryCode: CountryCode) =
        let output = CountryCode.asString countryCode
        
        CountryCodeSizedString.valid (CountryCodeSizedString output)
    
    let shrink = shrink valid

type UnclassifiedMarking = UnclassifiedMarking of Classification with
    static member op_Explicit(UnclassifiedMarking i) = i
    
    static member generator =
        Gen.constant Unclassified
        |> Gen.map UnclassifiedMarking
    
    static member valid (UnclassifiedMarking classification) =
        match classification with
        | Unclassified -> true
        | _ -> false
    
    static member shrink = shrink UnclassifiedMarking.valid

type ClassifiedMarking = ClassifiedMarking of Classification with
    static member op_Explicit(ClassifiedMarking i) = i
    
    static member generator =
        Arb.generate<Classified>
        |> Gen.map Classified
        |> Gen.map ClassifiedMarking
    
    static member valid (ClassifiedMarking classification) =
        match classification with
        | Classified _ -> true
        | _ -> false
    
    static member shrink = shrink ClassifiedMarking.valid

type ForeignClassificationUSMarking = ForeignClassificationUSMarking of Classification with
    static member op_Explicit(ForeignClassificationUSMarking i) = i
    
    static member generator =
        Arb.generate<USMarking>
        |> Gen.map USMarking
        |> Gen.map Foreign
        |> Gen.map Classified
        |> Gen.map ForeignClassificationUSMarking
    
    static member valid (ForeignClassificationUSMarking classification) =
        match classification with
        | Classified (Foreign (USMarking _)) -> true
        | _ -> false
    
    static member shrink = shrink ForeignClassificationUSMarking.valid

type NatoClassificationMarking = NatoClassificationMarking of Classification with
    static member op_Explicit(NatoClassificationMarking i) = i
    
    static member generator =
        Arb.generate<NatoClassification>
        |> Gen.map Nato
        |> Gen.map Classified
        |> Gen.map NatoClassificationMarking
    
    static member valid (NatoClassificationMarking _) =
        // todo
        true
    
    static member shrink = shrink NatoClassificationMarking.valid

let isFGIOriginalClassification classification =
    match classification with
    | Classified (Foreign (OriginalMarking _)) -> true
    | _ -> false

type NonFGIOriginalClassification = NonFGIOriginalClassification of Classification with
    static member op_Explicit(NonFGIOriginalClassification i) = i
    
    static member generator =
        Arb.generate<Classified>
        |> Gen.filter (Classified >> (not << isFGIOriginalClassification))
        |> Gen.map Classified
        |> Gen.map NonFGIOriginalClassification
    
    static member valid (NonFGIOriginalClassification c) =
        c |> (not << isFGIOriginalClassification)
    
    static member shrink = shrink NonFGIOriginalClassification.valid

module BannerLine =
    let generator =
        Arb.generate<NonFGIOriginalClassification list>
        |> Gen.map (fun c -> c |> List.map (fun (NonFGIOriginalClassification c') -> c'))
        |> Gen.map BannerLine.create
        |> Gen.map (fun bannerLine ->
            match bannerLine with
            | Ok bannerLine -> bannerLine
            | Error ForeignMarkingPresent -> failwith "Error generating Banner Line in generator due to Foreign Marking Present"
            | Error (AmbiguousMerger (c, m) ) -> failwith $"Error generating Banner Line in generator due to Ambiguous Merger between {c} and {m}"
            )
    
    let valid (_: BannerLine) =
        true
    
    let shrink = shrink valid
        

type ClassificationGenerators =
    static member TrigraphSizedString () =
        Arb.fromGenShrink (TrigraphSizedString.generator, TrigraphSizedString.shrink)
    
    static member NonTrigraphSizedString () =
        Arb.fromGenShrink (NonTrigraphSizedString.generator, NonTrigraphSizedString.shrink)
    
    static member TetragraphSizedString () =
        Arb.fromGenShrink (TetragraphSizedString.generator, TetragraphSizedString.shrink)
    
    static member NonTetragraphSizedString () =
        Arb.fromGenShrink (NonTetragraphSizedString.generator, NonTetragraphSizedString.shrink)
    
    static member CountryCodeSizedString () =
        Arb.fromGenShrink (CountryCodeSizedString.generator, CountryCodeSizedString.shrink)
    
    static member NonCountryCodeSizedString () =
        Arb.fromGenShrink (NonCountryCodeSizedString.generator, NonCountryCodeSizedString.shrink)
    
    static member CountryCode () =
        Arb.fromGenShrink (CountryCode.generator, CountryCode.shrink)
    
    static member UnclassifiedMarking () =
        Arb.fromGenShrink (UnclassifiedMarking.generator, UnclassifiedMarking.shrink)
    
    static member ClassifiedMarking () =
        Arb.fromGenShrink (ClassifiedMarking.generator, ClassifiedMarking.shrink)

    static member ForeignClassification () =
        Arb.fromGenShrink (ForeignClassificationUSMarking.generator, ForeignClassificationUSMarking.shrink)
    
    static member NatoClassification () =
        Arb.fromGenShrink (NatoClassificationMarking.generator, NatoClassificationMarking.shrink)
    
    static member NonFGIOriginalClassification () =
        Arb.fromGenShrink (NonFGIOriginalClassification.generator, NonFGIOriginalClassification.shrink)
    
    static member BannerLine () =
        Arb.fromGenShrink (BannerLine.generator, BannerLine.shrink)

type ClassificationPropertyAttribute () =
    inherit PropertyAttribute(Arbitrary = [| typeof<ClassificationGenerators> |])

module TestHelpers =
    let private openingParenthesis = "\("
    let private closingParenthesis = "\)"
    let private doubleSlash = @"(\/{2})"
    let private countryCode = @"(\w{3,4})"
    let private foreignDesignatorBanner = @"(TOP SECRET|SECRET|CONFIDENTIAL|RESTRICTED|UNCLASSIFIED)"
    let private foreignDesignatorPortion = @"(TS|S|C|R|U)"
    let private fullNatoClassification = @"(COSMIC TOP SECRET|COSMIC TOP SECRET BOHEMIA|NATO SECRET|NATO CONFIDENTIAL|NATO RESTRICTED|NATO UNCLASSIFIED|COSMIC TOP SECRET ATOMAL|SECRET ATOMAL|CONFIDENTIAL ATOMAL)"
    let private abbreviatedNatoClassification = @"(CTS|CTS-B|NS|NC|NR|NU|CTS-A|NS-A|NC-A)"
    let fgiBannerFormat = $"^{doubleSlash}{countryCode} {foreignDesignatorBanner}$"
    let fgiPortionFormat = $"^{openingParenthesis}{doubleSlash}{countryCode} {foreignDesignatorPortion}{closingParenthesis}$"
    let natoBannerFormat = $"^{doubleSlash}{fullNatoClassification}$"
    let natoPortionFormat = $"^{openingParenthesis}{doubleSlash}{abbreviatedNatoClassification}{closingParenthesis}$"
    
    let bannerLineStr (bannerLineResult: Result<BannerLine, CreateBannerLineError>) =
        match bannerLineResult with
        | Ok bannerLine -> bannerLine.asString
        | Error _ -> "Unable to create banner line"
    
    let portionMarkStr classification (bannerLineResult: Result<BannerLine, CreateBannerLineError>) =
        match bannerLineResult with
        | Ok bannerLine ->
            PortionMark.create bannerLine classification
            |> PortionMark.asString
        | Error _ -> "Unable to create banner line"

let (|Regex|_|) pattern input =
    let m = Regex.Match(input, pattern)
    if m.Success then Some(List.tail [ for g in m.Groups -> g.Value ])
    else None

let (===) left right = left = right |@ $"%A{left} != %A{right}"

let (.*) input pattern = Regex.Match(input, pattern).Success |@ $"String: '{input}' doesn't match the pattern."

let trimParenthesis (str: string) =
    str
    |> fun s -> if s.StartsWith "(" then s.Substring 1 else s
    |> fun s -> if s.EndsWith  ")" then s.Substring (0, s.Length - 1) else s

let isOk result =
    match result with
    | Ok _ -> true
    | Error _ -> false

let isError expectedError result =
    match result with
    | Ok _ -> false
    | Error error -> error = expectedError

open System

let ofOption error = function Some s -> Ok s | None -> Error error

type ResultBuilder() =
    member this.Return(x) = Ok x

    member this.ReturnFrom(m: Result<_, _>) = m

    member this.Bind(m, f) = Result.bind f m
    member this.Bind((m, error): Option<'T> * 'E, f) = m |> ofOption error |> Result.bind f

    member this.Zero() = None

    member this.Combine(m, f) = Result.bind f m

    member this.Delay(f: unit -> _) = f

    member this.Run(f) = f()

    member this.TryWith(m, h) =
        try this.ReturnFrom(m)
        with e -> h e

    member this.TryFinally(m, compensation) =
        try this.ReturnFrom(m)
        finally compensation()

    member this.Using(res:#IDisposable, body) =
        this.TryFinally(body res, fun () -> match res with null -> () | disp -> disp.Dispose())

    member this.While(guard, f) =
        if not (guard()) then Ok () else
        do f() |> ignore
        this.While(guard, f)

    member this.For(sequence:seq<_>, body) =
        this.Using(sequence.GetEnumerator(), fun enum -> this.While(enum.MoveNext, this.Delay(fun () -> body enum.Current)))

let result = ResultBuilder()