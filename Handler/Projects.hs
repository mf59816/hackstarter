module Handler.Projects where

import Import

getProjectsR :: Handler Html
getProjectsR = do
  projs <- runDB $ selectList [] [] 
  defaultLayout $ [whamlet|
    <h2>You are in the Projects:
    <ul>
    $forall Entity projId proj <- projs
      <li> #{projectName proj}
    <a href=@{AddProjectR}>add new project
    |]

postProjectsR :: Handler Html
postProjectsR = error "Not yet implemented: postProjectsR"
