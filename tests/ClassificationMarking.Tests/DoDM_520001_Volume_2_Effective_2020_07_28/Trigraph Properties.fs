module DoDM_520001_Volume_2_Effective_2020_07_28.``Trigraph Properties``

open Xunit
open Types
open Common
    
[<ClassificationProperty>]
let ``Trigraph can be created using a three character string`` (TrigraphSizedString str) =
    let output = Trigraph.tryCreate str
    
    output |> isOk

[<ClassificationProperty>]
let ``Trigraph value can be retrieved`` (TrigraphSizedString str) =
    let defaultValue value result =
        match result with
        | Ok value -> value
        | Error _ -> value
    
    let output =
        Trigraph.tryCreate str
        |> Result.map Trigraph.asString
        |> defaultValue "Trigraph wasn't created"
    
    output === str

[<ClassificationProperty>]
let ``Trigraph can not be created using strings that are not three characters`` (NonTrigraphSizedString str) =
    let output = Trigraph.tryCreate str
    
    output |> isError TrigraphError.InvalidLength

[<Fact>]
let ``Trigraph can not be created using a string that is null`` () =
    let output = Trigraph.tryCreate null
    
    Assert.True( output |> isError TrigraphError.NullString)