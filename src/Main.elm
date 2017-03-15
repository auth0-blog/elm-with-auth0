port module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Auth0
import Authentication


main : Program (Maybe Auth0.LoggedInUser) Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { authModel : Authentication.Model
    }


-- Init

init : Maybe Auth0.LoggedInUser -> ( Model, Cmd Msg )
init initialUser =
    ( Model (Authentication.init auth0showLock auth0logout initialUser), Cmd.none )


-- Messages

type Msg
    = AuthenticationMsg Authentication.Msg


-- Ports

port auth0showLock : Auth0.Options -> Cmd msg
port auth0authResult : (Auth0.RawAuthenticationResult -> msg) -> Sub msg
port auth0logout : () -> Cmd msg


-- Update

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AuthenticationMsg authMsg ->
            let
                ( authModel, cmd ) =
                    Authentication.update authMsg model.authModel
            in
                ( { model | authModel = authModel }, Cmd.map AuthenticationMsg cmd )



-- Subscriptions

subscriptions : a -> Sub Msg
subscriptions model =
    auth0authResult (Authentication.handleAuthResult >> AuthenticationMsg)


-- View

view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "jumbotron text-center" ]
            [ div []
                (case Authentication.tryGetUserProfile model.authModel of
                    Nothing ->
                        [ p [] [ text "Please log in" ] ]

                    Just user ->
                        [ p [] [ img [ src user.picture ] [] ]
                        , p [] [ text ("Hello, " ++ user.name ++ "!") ]
                        ]
                )
            , p []
                [ button
                    [ class "btn btn-primary"
                    , onClick
                        (AuthenticationMsg
                            (if Authentication.isLoggedIn model.authModel then
                                Authentication.LogOut
                                else
                                Authentication.ShowLogIn
                            )
                        )
                    ]
                    [ text
                        (if Authentication.isLoggedIn model.authModel then
                            "Logout"
                            else
                            "Login"
                        )
                    ]
                ]
            ]
        ]
