module DoDM_520001_Volume_2_Effective_2020_07_28.``Tetragraph Properties``

open Xunit
open Types
open Common


[<ClassificationProperty>]
let ``Tetragraph can be created using a four character string`` (TetragraphSizedString str) =
    let output = Tetragraph.tryCreate str
    
    output |> isOk

[<ClassificationProperty>]
let ``Tetragraph value can be retrieved`` (TetragraphSizedString str) =
    let defaultValue value result =
        match result with
        | Ok value -> value
        | Error _ -> value
    
    let output =
        Tetragraph.tryCreate str
        |> Result.map Tetragraph.asString
        |> defaultValue "Tetragraph wasn't created"
    
    output === str

[<ClassificationProperty>]
let ``Tetragraph can not be created using strings that are not four characters`` (NonTetragraphSizedString str) =
    let output = Tetragraph.tryCreate str
    
    output |> isError TetragraphError.InvalidLength

[<Fact>]
let ``Tetragraph can not be created using a string that is null`` () =
    let output = Tetragraph.tryCreate null
    
    Assert.True( output |> isError TetragraphError.NullString )

