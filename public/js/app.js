angular.module('CanIUseApp', [])
  .run(function($http) {
    $http.defaults.headers.common.Accept = 'application/json';
  })
  .value('apiUrl', '/api/v1')
  .service('apiClient', ['$http', 'apiUrl', function($http, apiUrl) {
    return {
      check: function(domain) {
        return $http.get(apiUrl + '/' + domain)
      }
    };
   }])
  .controller('homeCtrl', ['$scope', 'apiClient', function($scope, apiClient) {
    $scope.check = function(e) {
      e.preventDefault();
      apiClient.check($scope.domain).then(function(res) {
        if (res.data.error) {
          $scope.message = null;
          $scope.error = res.data.message;
        } else {
          $scope.error = null;
          $scope.message = "Domain: " + $scope.domain + ' is ' + (res.data.available ? 'available' : 'taken');
        }
      });
      return false;
    };
  }]);
