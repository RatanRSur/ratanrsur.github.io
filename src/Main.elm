module Main exposing (main)

import Html exposing (Html)
import TypedSvg exposing (polygon, svg)
import TypedSvg.Attributes exposing (class, height, id, points, width)
import TypedSvg.Types exposing (Length(..), pc, pt)


main : Html a
main =
    svg
        [ id "color-fill", width (pc 100), height (pt 300) ]
        [ polygon
            [ class [ "hex" ], points [ ( 300, 150 ), ( 225, 280 ), ( 75, 280 ), ( 0, 150 ), ( 75, 20 ), ( 225, 20 ) ] ]
            []
        ]
