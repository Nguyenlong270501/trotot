class PropertyReviewModel {
  final String id;
  final String authorName;
  final String authorInitials;
  final double rating;
  final String content;
  final DateTime createdAt;
 
  const PropertyReviewModel({
    required this.id,
    required this.authorName,
    required this.authorInitials,
    required this.rating,
    required this.content,
    required this.createdAt,
  });
}
 
class RatingDistribution {
  final int star5;
  final int star4;
  final int star3;
  final int star2;
  final int star1;
 
  const RatingDistribution({
    required this.star5,
    required this.star4,
    required this.star3,
    required this.star2,
    required this.star1,
  });
 
  int get total => star5 + star4 + star3 + star2 + star1;
  double fractionFor(int star) {
    if (total == 0) return 0;
    switch (star) {
      case 5: return star5 / total;
      case 4: return star4 / total;
      case 3: return star3 / total;
      case 2: return star2 / total;
      case 1: return star1 / total;
      default: return 0;
    }
  }
 
  int countFor(int star) {
    switch (star) {
      case 5: return star5;
      case 4: return star4;
      case 3: return star3;
      case 2: return star2;
      case 1: return star1;
      default: return 0;
    }
  }
}