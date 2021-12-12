module DoDM_520001_Volume_2_Effective_2020_07_28.``Country Code Properties``

open Xunit
open Types
open Common



[<ClassificationProperty>]
let ``Country Code can be created using a three letter ISO-3166 standard trigraph or four letter organization/alliance tetragraph - Enclosure 4 (1.e)`` (CountryCodeSizedString str) =
    let output = CountryCode.tryCreate str
    
    output |> isOk

[<ClassificationProperty>]
let ``Country Code value matches the original input`` (CountryCodeSizedString str) =
    let defaultValue value result =
        match result with
        | Ok value -> value
        | Error _ -> value
    
    let output =
        CountryCode.tryCreate str
        |> Result.map CountryCode.asString
        |> defaultValue "Tetragraph wasn't created"
    
    output === str

[<ClassificationProperty>]
let ``Country Code can not be created when the input is not a trigraph or tetragraph`` (NonCountryCodeSizedString str) =
    let output = CountryCode.tryCreate str
    
    output |> isError CountryCodeError.InvalidLength

[<Fact>]
let ``Country Code can not be created when the input is null`` () =
    let output = CountryCode.tryCreate null
    
    Assert.True( output |> isError CountryCodeError.NullString )

