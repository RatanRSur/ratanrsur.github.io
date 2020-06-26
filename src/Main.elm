module Main exposing (main)

import Html exposing (Html, div)
import List exposing (foldl, head, sortBy)
import Maybe exposing (andThen)
import TypedSvg exposing (circle, svg)
import TypedSvg.Attributes exposing (cx, cy, height, r, width)
import TypedSvg.Types exposing (Length(..), pc, px)


type alias Point =
    { x : Float
    , y : Float
    }


type alias Circumcircle =
    { center : Point
    , radius : Float
    , circumscribedPoints : List Point
    }


testPoints : List Point
testPoints =
    [ { x = 700, y = 200 }
    , { x = 450, y = 450 }
    , { x = 300, y = 200 }
    , { x = 200, y = 500 }
    , { x = 500, y = 200 }
    , { x = 20, y = 20 }
    , { x = 20, y = 20 }
    , { x = 500, y = 220 }
    , { x = 30, y = 150 }
    , { x = 700, y = 700 }
    ]


dot : Point -> Html.Html msg
dot center =
    circle [ cx (px center.x), cy (px center.y), r (px 5) ] []



-- see http://www.s-hull.org/paper/s_hull.pdf


euclidian : Point -> Point -> Float
euclidian p1 p2 =
    sqrt ((p1.x - p2.x) ^ 2 + (p1.y - p2.y) ^ 2)


circumcircle : Point -> Point -> Point -> Circumcircle
circumcircle a b c =
    let
        d =
            1 / (2 * (a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y)))

        center =
            { x = d * ((a.x ^ 2 + a.y ^ 2) * (b.y - c.y) + (b.x ^ 2 + b.y ^ 2) * (c.y - a.y) + (c.x ^ 2 + c.y ^ 2) * (a.y - b.y))
            , y = d * ((a.x ^ 2 + a.y ^ 2) * (c.x - b.x) + (b.x ^ 2 + b.y ^ 2) * (a.x - c.x) + (c.x ^ 2 + c.y ^ 2) * (b.x - a.x))
            }
    in
    { center = center
    , radius = euclidian a center
    , circumscribedPoints = [ a, b, c ]
    }


smallestCircumcircle : List Point -> Maybe ( Circumcircle, List Point )
smallestCircumcircle points =
    head points
        |> andThen
            (\seedPoint ->
                case sortBy (euclidian seedPoint) points of
                    --we want to make sure we have at least 3 points in the list
                    alsoSeedPoint :: seedClosestToPoint :: initialThirdPoint :: rest ->
                        -- find, from among all the points, the smallest circumcircle that includes the seed point and the point closest to the seed point
                        Just
                            (let
                                fullyDeterminedCircle =
                                    circumcircle alsoSeedPoint seedClosestToPoint

                                evaluateCandidatePoint candidatePoint ( bestPoint, bestCircle, eliminatedPoints ) =
                                    let
                                        candidateCircle =
                                            fullyDeterminedCircle candidatePoint
                                    in
                                    if candidateCircle.radius < bestCircle.radius then
                                        ( candidatePoint, candidateCircle, bestPoint :: eliminatedPoints )

                                    else
                                        ( bestPoint, bestCircle, candidatePoint :: eliminatedPoints )

                                ( _, finalCircle, otherPoints ) =
                                    foldl
                                        evaluateCandidatePoint
                                        ( initialThirdPoint, fullyDeterminedCircle initialThirdPoint, [] )
                                        rest
                             in
                             ( finalCircle, otherPoints )
                            )

                    _ ->
                        Nothing
            )


main : Html a
main =
    --let
    --debug =
    --Debug.log
    --"smallest circle"
    --(case points of
    --seedPoint :: secondPointCandidates ->
    --let
    --sortedByDistance =
    --sortBy (euclidian seedPoint) secondPointCandidates
    --in
    --case sortedByDistance of
    --closestPoint :: thirdPointCandidates ->
    --case head (sortBy (\otherPoint -> (circumcircle seedPoint closestPoint otherPoint).radius) thirdPointCandidates) of
    --Just smallestCirclePoint ->
    --[ seedPoint, closestPoint, smallestCirclePoint ]
    --Nothing ->
    --[]
    --_ ->
    --[]
    --_ ->
    --[]
    --)
    --in
    div
        []
        [ svg [ height (pc 100), width (pc 100) ] (List.map dot testPoints) ]
