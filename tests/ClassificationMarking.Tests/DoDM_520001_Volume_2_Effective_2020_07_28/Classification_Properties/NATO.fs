module DoDM_520001_Volume_2_Effective_2020_07_28.Classification_Properties.NATO

open Common
open Types
open Xunit
open FsCheck

[<Fact>]
let ``NatoClassification.fullName returns "COSMIC TOP SECRET" for NatoClassification.CosmicTopSecret`` () =
    Assert.True(NatoClassification.fullName NatoClassification.CosmicTopSecret = "COSMIC TOP SECRET")

[<Fact>]
let ``NatoClassification.fullName returns "COSMIC TOP SECRET BOHEMIA" for NatoClassification.CosmicTopSecretBohemia`` () =
    Assert.True(NatoClassification.fullName NatoClassification.CosmicTopSecretBohemia = "COSMIC TOP SECRET BOHEMIA")

[<Fact>]
let ``NatoClassification.fullName returns "NATO SECRET" for NatoClassification.NatoSecret`` () =
    Assert.True(NatoClassification.fullName NatoClassification.NatoSecret = "NATO SECRET")

[<Fact>]
let ``NatoClassification.fullName returns "NATO CONFIDENTIAL" for NatoClassification.NatoConfidential`` () =
    Assert.True(NatoClassification.fullName NatoClassification.NatoConfidential = "NATO CONFIDENTIAL")

[<Fact>]
let ``NatoClassification.fullName returns "NATO RESTRICTED" for NatoClassification.NatoRestricted`` () =
    Assert.True(NatoClassification.fullName NatoClassification.NatoRestricted = "NATO RESTRICTED")

[<Fact>]
let ``NatoClassification.fullName returns "NATO UNCLASSIFIED" for NatoClassification.NatoUnclassified`` () =
    Assert.True(NatoClassification.fullName NatoClassification.NatoUnclassified = "NATO UNCLASSIFIED")

[<Fact>]
let ``NatoClassification.fullName returns "COSMIC TOP SECRET ATOMAL" for NatoClassification.CosmicTopSecretAtomal`` () =
    Assert.True(NatoClassification.fullName NatoClassification.CosmicTopSecretAtomal = "COSMIC TOP SECRET ATOMAL")

[<Fact>]
let ``NatoClassification.fullName returns "SECRET ATOMAL" for NatoClassification.SecretAtomal`` () =
    Assert.True(NatoClassification.fullName NatoClassification.SecretAtomal = "SECRET ATOMAL")

[<Fact>]
let ``NatoClassification.fullName returns "CONFIDENTIAL ATOMAL" for NatoClassification.ConfidentialAtomal`` () =
    Assert.True(NatoClassification.fullName NatoClassification.ConfidentialAtomal = "CONFIDENTIAL ATOMAL")

[<Fact>]
let ``NatoClassification.abbreviation returns "CTS" for NatoClassification.CosmicTopSecret`` () =
    Assert.True(NatoClassification.abbreviation NatoClassification.CosmicTopSecret = "CTS")

[<Fact>]
let ``NatoClassification.abbreviation returns "CTS-B" for NatoClassification.CosmicTopSecretBohemia`` () =
    Assert.True(NatoClassification.abbreviation NatoClassification.CosmicTopSecretBohemia = "CTS-B")

[<Fact>]
let ``NatoClassification.abbreviation returns "NS" for NatoClassification.NatoSecret`` () =
    Assert.True(NatoClassification.abbreviation NatoClassification.NatoSecret = "NS")

[<Fact>]
let ``NatoClassification.abbreviation returns "NC" for NatoClassification.NatoConfidential`` () =
    Assert.True(NatoClassification.abbreviation NatoClassification.NatoConfidential = "NC")

[<Fact>]
let ``NatoClassification.abbreviation returns "NR" for NatoClassification.NatoRestricted`` () =
    Assert.True(NatoClassification.abbreviation NatoClassification.NatoRestricted = "NR")

[<Fact>]
let ``NatoClassification.abbreviation returns "NU" for NatoClassification.NatoUnclassified`` () =
    Assert.True(NatoClassification.abbreviation NatoClassification.NatoUnclassified = "NU")

[<Fact>]
let ``NatoClassification.abbreviation returns "CTS-A" for NatoClassification.CosmicTopSecretAtomal`` () =
    Assert.True(NatoClassification.abbreviation NatoClassification.CosmicTopSecretAtomal = "CTS-A")

[<Fact>]
let ``NatoClassification.abbreviation returns "NS-A" for NatoClassification.SecretAtomal`` () =
    Assert.True(NatoClassification.abbreviation NatoClassification.SecretAtomal = "NS-A")

[<Fact>]
let ``NatoClassification.abbreviation returns "NC-A" for NatoClassification.ConfidentialAtomal`` () =
    Assert.True(NatoClassification.abbreviation NatoClassification.ConfidentialAtomal = "NC-A")


[<ClassificationProperty>]
let ``Documents consisting entirely of NATO information shall have a portion marks consisting only of NATO markings - Enclosure 4 (4.b.2)`` () =
    // portion mark will need to be aware of overall classification
    
    false

[<ClassificationProperty>]
let ``Requirement - Enclosure 4 (4.b.4)`` () =
    (*
    When NATO information is incorporated into a U.S. document, the portion marking
    will be a NATO marking; however, the banner line will use the highest classification of
    information in the document (i.e., classification of the U.S. information or the U.S. equivalent
    classification for the NATO information, whichever is higher) with the addition of “//FGI
    NATO” (e.g., SECRET//FGI NATO). The statement “THIS DOCUMENT CONTAINS NATO (level of classification)
    INFORMATION” shall appear on the face of the document. See Section 9 of this enclosure for guidance
    on use of FGI markings in U.S. documents.
    *)
    
    false