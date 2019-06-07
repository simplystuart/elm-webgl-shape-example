module Main exposing (main)

import Browser
import Browser.Events
import Html exposing (Html)
import Html.Attributes exposing (..)
import Math.Matrix4 as Mat4
import Math.Vector2 as Vec2
import Math.Vector3 as Vec3
import Math.Vector4 as Vec4
import WebGL


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { time : Float
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { time = 0 }, Cmd.none )



-- UPDATE


type Msg
    = Animate Float


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Animate time ->
            ( { model | time = model.time + time }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ Browser.Events.onAnimationFrameDelta Animate ]



-- VIEW


view : Model -> Html Msg
view { time } =
    WebGL.toHtml
        [ width 500
        , height 500
        , style "display" "block"
        ]
        [ WebGL.entity
            vertexShader
            fragmentShader
            mesh
            { resolution = Vec2.vec2 500.0 500.0
            , transform = Mat4.makeRotate (time / 1000) Vec3.k
            }
        ]



-- MESH


type alias Vertex =
    { position : Vec2.Vec2 }


mesh : WebGL.Mesh Vertex
mesh =
    WebGL.triangles
        [ ( Vertex (Vec2.vec2 -1 -1)
          , Vertex (Vec2.vec2 1 -1)
          , Vertex (Vec2.vec2 1 1)
          )
        , ( Vertex (Vec2.vec2 -1 -1)
          , Vertex (Vec2.vec2 -1 1)
          , Vertex (Vec2.vec2 1 1)
          )
        ]



-- SHADERS


type alias Uniforms =
    { resolution : Vec2.Vec2, transform : Mat4.Mat4 }


type alias Varyings =
    {}


vertexShader : WebGL.Shader Vertex Uniforms Varyings
vertexShader =
    [glsl|

    precision mediump float;

    attribute vec2 position;
    uniform mat4 transform;
    uniform vec2 resolution;

    void main () {
      gl_Position = vec4(position, 0, 1);
    }

    |]


fragmentShader : WebGL.Shader {} Uniforms Varyings
fragmentShader =
    [glsl|

      precision mediump float;

      uniform vec2 resolution;

      float circle(in vec2 _st, in float _radius){
        vec2 dist = _st-vec2(0.5);
        return 1.-smoothstep(_radius-(_radius*0.01), _radius+(_radius*0.01), dot(dist,dist)*4.0);
      }


      void main () {
        vec2 st = gl_FragCoord.xy/resolution;

        vec3 color = vec3(circle(st,0.9));

        gl_FragColor = vec4(color, 1.0);
      }
    |]
