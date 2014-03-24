String.prototype.capitalize = ()->
    this.charAt(0).toUpperCase() + this.substring(1).toLowerCase()