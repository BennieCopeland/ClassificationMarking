module DoDM_520001_Volume_2_Effective_2020_07_28.Marking_Properties.``Document Markings``

open Common
open Types

[<ClassificationProperty>]
let ``US Marked FGI that is "RESTRICTED" will have the "CONFIDENTIAL - Modified Handling" document marking - Enclosure 4 (f.c.2)`` () =
    false

[<ClassificationProperty>]
let ``US Marked FGI that is "UNCLASSIFIED" by provided "in confidence" will have the "CONFIDENTIAL - Modified Handling" document marking - Enclosure 4 (f.c.2)`` () =
    false