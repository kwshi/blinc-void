module Main exposing (..)

import Browser
import Html


type Model
    = Model {}


type Msg
    = Nop


main : Program () Model Msg
main =
    Browser.application
        { init = \() _ _ -> ( Model {}, Cmd.none )
        , onUrlChange = always Nop
        , onUrlRequest = always Nop
        , subscriptions = always Sub.none
        , update = update
        , view = view
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "hi"
    , body =
        [ Html.div [] [ Html.text "hello" ]
        ]
    }
