module DoDM_520001_Volume_2_Effective_2020_07_28.Classification_Properties.``ForeignDesignator Properties``

open Xunit
open Common
open Types

[<Fact>]
let ``ForeignDesignator.fullName returns "TOP SECRET" for ForeignDesignator.TopSecret`` () =
    Assert.True (ForeignDesignator.fullName ForeignDesignator.TopSecret = "TOP SECRET")

[<Fact>]
let ``ForeignDesignator.fullName returns "SECRET" for ForeignDesignator.Secret`` () =
    Assert.True (ForeignDesignator.fullName ForeignDesignator.Secret = "SECRET")
    
[<Fact>]
let ``ForeignDesignator.fullName returns "CONFIDENTIAL" for ForeignDesignator.Confidential`` () =
    Assert.True (ForeignDesignator.fullName ForeignDesignator.Confidential = "CONFIDENTIAL")
    
[<Fact>]
let ``ForeignDesignator.fullName returns "RESTRICTED" for ForeignDesignator.Restricted`` () =
    Assert.True (ForeignDesignator.fullName ForeignDesignator.Restricted = "RESTRICTED")

[<ClassificationProperty>]
let ``ForeignDesignator.fullName returns "UNCLASSIFIED" for ForeignDesignator.Unclassified`` (providedInConfidence: bool) =
    ForeignDesignator.fullName (ForeignDesignator.Unclassified providedInConfidence) = "UNCLASSIFIED"

[<Fact>]
let ``ForeignDesignator.abbreviation returns "TS" for ForeignDesignator.TopSecret`` () =
    Assert.True (ForeignDesignator.abbreviation ForeignDesignator.TopSecret = "TS")

[<Fact>]
let ``ForeignDesignator.abbreviation returns "S" for ForeignDesignator.Secret`` () =
    Assert.True (ForeignDesignator.abbreviation ForeignDesignator.Secret = "S")
    
[<Fact>]
let ``ForeignDesignator.abbreviation returns "C" for ForeignDesignator.Confidential`` () =
    Assert.True (ForeignDesignator.abbreviation ForeignDesignator.Confidential = "C")
    
[<Fact>]
let ``ForeignDesignator.abbreviation returns "R" for ForeignDesignator.Restricted`` () =
    Assert.True (ForeignDesignator.abbreviation ForeignDesignator.Restricted = "R")

[<ClassificationProperty>]
let ``ForeignDesignator.abbreviation returns "U" for ForeignDesignator.Unclassified`` (providedInConfidence: bool) =
    ForeignDesignator.abbreviation (ForeignDesignator.Unclassified providedInConfidence) = "U"